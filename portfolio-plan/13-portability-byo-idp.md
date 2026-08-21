# BYO IdP 接続手順（Collab／AuthPort）

| 項目 | 値 |
| --- | --- |
| 最終更新 | 2026-08-21 |
| 契約の正本 | [12-portability.md](./12-portability.md) |

同梱 P01 の代わりに、顧客またはラボの OIDC IdP（Entra、Auth0、Keycloak 等）を使う。  
**ポートフォリオデモでは Auth0 / Entra への実接続確認はしない。** 実装と設定例のみ用意（製品側 `pf-workspace/deploy/byo-oidc/AUTH0-ENTRA.md`）。

## 前提

- Authorization Code + PKCE
- discovery 対応（jwks / userinfo / 任意で end_session）
- `sub` 必須
- テナント: `OIDC_ORG_CLAIM`（既定 `org_id`、フォールバックに `tid` 等）

## チェックリスト（顧客環境向け・未実施可）

1. IdP にアプリ登録: redirect `…/callback`、logout redirect
2. `OIDC_ISSUER` / `OIDC_CLIENT_ID` / 必要なら `OIDC_CLIENT_SECRET`・`OIDC_AUDIENCE`
3. カスタムクレームを `OIDC_ORG_CLAIM` / `OIDC_ORGS_CLAIM` に合わせる
4. Auth0/Entra では `OIDC_SCOPES` から独自 `org` scope を外す
5. `WORKSPACE_ENV=staging`、`WORKSPACE_DEV_AUTH=false`
6. （任意）ログイン → org 切替 → 境界確認

ラボ代替: `pf-workspace/deploy/byo-oidc` の mock OIDC。

## P01 固有 API への依存

| 機能 | 同梱 P01 | BYO |
| --- | --- | --- |
| `/v1/active-org` | 使用 | Cookie + `X-Workspace-Org` |
| `/v1/organizations/.../members` | 使用 | workspace メンバー列挙にフォールバック |
| 標準 OIDC + discovery | 使用 | 必須 |
