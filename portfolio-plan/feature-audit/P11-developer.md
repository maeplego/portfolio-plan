# P11 developer-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-developer-cli`、`templates`、`scanner`、`portal`、`ci-dash`、`review` |
| 設計 | [developer-platform/DESIGN.md](../developer-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |
| K8s 注意 | **portal のみ** overlay 搭載。他はホスト／Compose |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P11** |
| 元アイデア | 08 レビュー、15 CI、21 scanner、23 CLI、29 OpenAPI ポータル |
| 役割 | 内部開発者プラットフォームのミニ版。「作る → 仕様を見る → CI → PR → スキャン」の一本線 |
| 構成 | ポリレポ 6＋未着手 `pf-developer-web`（横断シェルは portal ホームのリンクで代替） |

| リポ | 役割 | K8s |
| --- | --- | --- |
| `pf-developer-cli` | `pf-dev new` / `scan` | **非搭載**（ホスト CLI） |
| `pf-developer-templates` | `go-api` / `go-next` 実ファイル雛形 | **非搭載** |
| `pf-developer-scanner` | OSV／Dockerfile／シークレット診断 | **非搭載**（意図的 MVP） |
| `pf-developer-portal` | OpenAPI カタログ・モック・oasdiff | **搭載**（b-collab / d-commerce / e-content、`portal.localhost`） |
| `pf-developer-ci-dash` | 公開 Actions 可視化 | **非搭載**（Compose のみ） |
| `pf-developer-review` | PR BFF | **非搭載**（Compose のみ） |

---

## 2. 目的・スコープ

**目的:** 標準で作る・仕様をゲートする・壊し方を防ぐ。攻撃ではなく修正。GitHub の完全クローンではない。

**含む:** scanner MVP、portal 手置き YAML＋example モック、CLI＋P04/P06 実テンプレ、oasdiff Action／`oasdiff-gate`、ci-dash allowlist、review BFF（ローカル path 拒否）、portal から他 URL へのリンク（`PORTAL_*_URL`）。

**技術:** CLI/scanner/portal/ci-dash/review は Go。テンプレは実ファイル＋`template.json`。脆弱性 DB は OSV（キャッシュ）。認証は公開 repo 読み取り中心。PAT は env のみ（git 禁止）。P01 ログインは未着手。

---

## 3. 実装済み機能

### 3.1 scanner（`go run ./cmd/scanner`）

- `go.mod`/`go.sum`、`package-lock.json` → OSV（`.scanner-cache`）
- Dockerfile: `:latest`／タグ無し（DOC001）、`USER root`／USER なし（DOC002）
- シークレット風正規表現 SEC001–006（レポートでマスク）
- `-offline`、`-min-severity`、`.scannerignore`
- 終了: 0 クリーン、1 finding、2 用法／OSV 不完全でグリーン偽装不可
- **無い:** exploit/PoC、任意 Git clone、poetry/requirements/IaC

### 3.2 CLI（`pf-dev`）

| コマンド | 内容 |
| --- | --- |
| `new` / `create` | `-t go-api\|go-next`、`--yes`、`-force`、`-o`、`--module` |
| `scan` | scanner を subprocess（`PF_DEV_SCANNER` / PATH / 兄弟 repo `go run`） |

env: `PF_DEV_TEMPLATES`、`PF_DEV_SCANNER`。postInstall 任意シェルは走らない。

### 3.3 templates

| テンプレ | 内容 |
| --- | --- |
| `go-api` | `/health` `/ready`、カタログ、OIDC userinfo スタブ、OTel env、Dockerfile 非 root 精神 |
| `go-next` | 上記＋Next（ヘルス・PKCE スタブ）。oasdiff workflow 同梱 |

### 3.4 portal（`:8111`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/` `/docs/{slug}` | カタログ／リファレンス HTML |
| GET | `/api/catalog` `/api/specs/{slug}` | JSON／YAML |
| POST | `/api/diff` | 本文 YAML のみ比較（URL fetch なし）。ERR は 409 |
| * | `/mock/{slug}/...` | example 優先。必須欠落 400、未知 404。永続化なし |
| GET | `/health` `/ready` | プローブ |

手置き slug: `payments`、`commerce-catalog`、`content-blog`。管理アップロードなし。`oasdiff-gate` + `.github/workflows/openapi-breaking.yml`。

### 3.5 ci-dash（`:8115`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/` `/repos/{owner}/{repo}` | allowlist HTML（`?path=` は 400） |
| GET | `/api/repos/.../runs` | JSON |
| POST | `/webhook/github` | HMAC `workflow_run`。secret 無しは 404 |

`CI_DASH_REPOS` 必須。任意 `GITHUB_TOKEN`（レート制限用）。履歴 Postgres・私有 repo・自前 runner なし。

### 3.6 review（`:8118`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/repos/.../pulls` `/pulls/{n}` | 一覧・diff・コメント（HTML エスケープ） |
| GET/POST | `/api/repos/.../pulls*` | JSON。コメント POST はトークン必須（無ければ 403） |

巨大 diff 切り詰め（約 40 ファイル／80KiB）。ローカル path・`..` アンカー拒否。自動 merge／LLM なし。

### 3.7 横断シェル

独立 `pf-developer-web` **未着手**。portal ホームが `PORTAL_CI_DASH_URL` / `PORTAL_REVIEW_URL` / `PORTAL_SCANNER_URL` でリンク（K8s portal マニフェスト既定は空）。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| GitHub 読み取り | 公開 API。任意 PAT は env |
| Webhook | `GITHUB_WEBHOOK_SECRET` HMAC |
| コメント書き込み | review の `GITHUB_TOKEN` |
| IdP | **未配線** |

テナント概念なし（repo allowlist）。主要 env: `PORTAL_*`、`CI_DASH_*`、`REVIEW_*`、`GITHUB_TOKEN`、`GITHUB_WEBHOOK_SECRET`、`PF_DEV_*`。

---

## 5. デモ起動

```powershell
# portal
cd pf-developer-portal; go test ./...; go run ./cmd/portal
# CLI
go run ./cmd/pf-dev new --yes demo
# scanner
go run ./cmd/scanner scan -offline testdata/clean
# ci-dash / review（Compose 可）
$env:CI_DASH_REPOS="oasdiff/oasdiff"; go run ./cmd/ci-dash
$env:REVIEW_REPOS="oasdiff/oasdiff"; go run ./cmd/review
```

| URL | 用途 |
| --- | --- |
| http://localhost:8111 | portal |
| http://localhost:8115 | ci-dash |
| http://localhost:8118 | review |
| http://portal.localhost | K8s（overlay B/D/E） |

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P04 / P06 | テンプレの実体ソース。生成物に health／OTel／OIDC stub／catalog |
| P01 | テンプレ内コメントのクライアント設定。ポータル自体のログインは未 |
| P02 | OTLP env をテンプレに。portal Deployment に OTEL 空文字可 |
| P08 / P06 | portal に content-blog / commerce-catalog 子集 |
| P17 精神 | Dockerfile 非 root（scanner DOC ルール） |

---

## 7. 非目標・名乗らないこと

GitHub 完全クローン、自動 merge ボット、公開マルチテナントでの任意 clone（SSRF）、exploit/PoC、フレーク検出、自前 CI ランナーでの不信コード実行、本番 IDP としての scanner SaaS。

---

## 8. テスト・ゲート

| 層 | 状態 |
| --- | --- |
| 各 `go test ./...` | 製品 AGENTS／README の正 |
| oasdiff fixture | breaking fail / compatible green |
| K8s | portal のみ image-catalog。ci-dash／review／scanner／cli **manifest なし** |
| バックログ | 公開 GitHub 読み取り中心。パッケージ販売時は PAT 運用が必須項 |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | **K8s 非搭載:** cli、templates、scanner、ci-dash、review | 意図的。scanner README 明示 |
| 2 | portal K8s に `PORTAL_*_URL` 未設定 | クラスタ上はリンク切れやすい |
| 3 | `pf-developer-web` 未着手 | DESIGN step 7 は portal リンクで完了扱い |
| 4 | P01 ログイン・PAT 暗号化保存なし | DESIGN 明記 |
| 5 | 管理画面からの spec アップロードなし | 受け入れに入れない |
| 6 | scanner は poetry / requirements / IaC 未対応 | MVP |
| 7 | ci-dash／review に顧客向け導入ガイドは薄い | バックログ推奨 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/developer-platform/DESIGN.md`、`docs/*`、`developer-platform/AGENTS.md`、idea 08/15/21/23/29
- 製品: 各 `pf-developer-*/README.md`、`cmd/*`、`internal/httpapi`
- K8s: `pf-cloud-k8s/.../portfolio-integration-b-collab`（及び d/e）の `pf-developer-portal` のみ、`ingress-p11.yaml`、`pf-developer-scanner/deploy/k8s/README.md`
