# P01 identity-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-identity` |
| 設計 | [identity-platform/DESIGN.md](../identity-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P01** |
| 元アイデア | 14 OAuth/OIDC IdP |
| 役割 | ポートフォリオ全体の **OIDC Identity Provider**（アカウント発行の正本） |
| 構成 | `apps/server`（Go IdP）、`apps/admin`（Next）、`apps/sample-rp`（接続確認）、`apps/e2e`（Playwright）、`deploy/` |

各製品はパスワードを持たず、認可コード + PKCE でログインする想定。

---

## 2. 目的・スコープ

**目的:** SSO 物語の基盤。学習用 IdP。商用 IdP の置き換えではない。

**含む:** 登録／ログイン、認可コード + PKCE、Consent、ID Token（RS256）／opaque access、Discovery／JWKS、refresh ローテーション、ログアウト連動（RP／Front／Back）、Admin API+UI、organizations（`org` scope）。

**技術:** Go + jwx、Argon2id、PostgreSQL または memory、Next admin／sample-rp。

---

## 3. 実装済み機能

### 3.1 エンドユーザー HTML（IdP）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/` | ホーム |
| GET/POST | `/register` | 登録 |
| GET/POST | `/login` | ログイン（レート制限あり） |
| POST | `/logout` | セッション終了 |
| GET | `/authorize` | 認可（`response_type=code`、PKCE S256 必須） |
| POST | `/consent` | 同意 |
| GET/POST | `/end-session` | RP-Initiated Logout |

### 3.2 OIDC / OAuth

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health` | liveness |
| POST | `/token` | `authorization_code` / `refresh_token` |
| GET | `/userinfo` | Bearer（opaque） |
| GET | `/.well-known/openid-configuration` | Discovery |
| GET | `/jwks.json`、`/.well-known/jwks.json` | JWKS |

**スコープ（実装）:** `openid`, `profile`, `email`, `offline_access`, **`org`**。

**ID Token:** `iss/sub/aud/exp/iat/nonce/sid/email/email_verified/name`。`org` 時は `org_id`, `org_role`。  
**UserInfo:** 上記 + `org` 時 `organizations[]`。

### 3.3 組織 API

| メソッド | パス | 認証 |
| --- | --- | --- |
| POST/GET | `/v1/organizations` | Bearer |
| GET | `/v1/organizations/{id}/members` | Bearer |
| PUT | `/account/active-org` | Cookie セッション |
| PUT | `/v1/active-org` | Bearer（`session_sid` 必須） |

### 3.4 Admin API（`IDENTITY_ADMIN_TOKEN`）

クライアント CRUD／secret ローテ、ユーザー無効化、監査一覧、組織・メンバー管理。トークン未設定時は `/admin/api/*` 利用不可。

### 3.5 Admin UI（`:3002`）／sample-rp（`:3001` / `:3003`）

クライアント・組織・ユーザー・監査画面。sample-rp は login／callback／logout／frontchannel／backchannel の見本。

### 3.6 無いもの（意図的）

OpenAPI、`/revoke`、introspection、device／client_credentials、PAR、CIBA、implicit、SAML、パスキー、ソーシャル仲介、メール検証、MFA。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| ユーザー | パスワード → Cookie `idp_session` |
| RP | public: PKCE／confidential: Basic または POST secret |
| 管理者 | `IDENTITY_ADMIN_TOKEN` |
| RS | opaque access + `/userinfo` |

**テナント:** `organizations` + memberships（`owner`｜`member`）。セッション `ActiveOrgID`。

**主要 env:** `IDENTITY_ENV`（staging+ は memory・dev key 禁止）、`IDENTITY_ISSUER`、`IDENTITY_STORE`、`IDENTITY_DATABASE_URL`、鍵パス／`DEV_GENERATE_KEYS`、TTL 群、seed クライアント／デモユーザー。

---

## 5. デモ起動

```powershell
copy deploy/.env.example deploy/.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:8080 | IdP |
| http://localhost:3001 | sample-rp |
| http://localhost:3003 | sample-rp-b |
| http://localhost:3002 | admin |

レビューパック: `pf-cloud-k8s` の `review-up.ps1 -Pack p01-p03`。K8s は `pf-cloud-k8s` overlay 経由（単体 apply 禁止）。

**注意:** 現行 Compose に `IDENTITY_SEED_DEMO_*` が無い。README の「Compose がデモユーザーを用意」は不一致。K8s overlay 側では seed あり。

---

## 6. 他 Pxx との契約

- 利用者主キーは **`sub`**（email 禁止）。
- `redirect_uri`／`post_logout_redirect_uri` 完全一致。
- org 消費者: P04（本線）、P03／P06／P09／P10 など（OIDC 時 `org_id`）。
- Compose seed に多数の `pf-*-web` クライアント。K8s `idp-env.yaml` の集合は Compose と完全一致しない（talent 等）。

---

## 7. 非目標・名乗らないこと

本番／商用 IdP 置き換え、常時公開テナント、SAML のみ SSO、暗号の自前実装。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `apps/server` `go test ./...` | **FAIL**: `TestOrganizationAPIAndOrgClaims`（`POST /v1/organizations` が 401） |
| CI | go test、govulncheck、Trivy、kustomize、compose config |
| e2e | Playwright（workflow_dispatch）。品質ゲート本線ではない |
| 書類 | staging プロファイル・監査・脅威モデルあり |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | ~~org API テスト失敗~~ | **対応済**（Clock とトークン期限） |
| 2 | ~~Discovery の `scopes_supported` に `org` 無し~~ | **対応済** |
| 3 | ~~`docs/05-api.md` が `/v1/*` org 系で薄い~~ | **対応済** |
| 4 | ~~Compose デモユーザー seed 不足~~ | **対応済**（`IDENTITY_SEED_DEMO_*`） |
| 5 | ID Token に `organizations[]` 無し | UserInfo のみ（対象外／後続可） |
| 6 | `/revoke`・introspection 未実装 | 対象外(C)／後回し |
| 7 | 監査イベント不足（login 成功、org 切替等） | 本番ゲート観点 |
| 8 | ~~K8s と Compose の seed クライアント差~~ | **文書化済** |

---

## 10. 根拠パス

- メタ: `portfolio-plan/identity-platform/DESIGN.md`、`docs/*`、`identity-platform/AGENTS.md`、`portfolio-idea/14-*.md`
- 製品: `pf-identity/apps/server/internal/web/*.go`、`deploy/compose.yaml`、`apps/admin`、`apps/sample-rp`
- 連携: `pf-cloud-k8s/.../patches/idp-env.yaml`
