# P03 media-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-media`（モノレポ: `apps/api` / `processor` / `web` + `deploy/`） |
| 設計 | [media-platform/DESIGN.md](../media-platform/DESIGN.md) |
| 元アイデア | 13 ファイル共有、28 画像パイプライン |

---

## 1. 識別

横断のオブジェクト保存＋画像派生基盤。Wiki／商品／ブログ／チャットが各自 S3 クライアントを持たないための共有能力。

---

## 2. 目的・スコープ

**含む:** presign PUT → complete、クォータ、フォルダ、期限付き共有（パスワード任意）、非同期派生（`orig`／`detail`／`thumb`）、マイドライブ UI、dev-auth または P01 OIDC＋org、Compose（Postgres＋Redis＋Garage＋api＋processor＋web）、顧客バケット差し替え手順。

**思想:** 実体は API メモリを通さない、権限の正はメタ DB、派生は非同期・冪等、マジックバイト／ピクセル上限／EXIF GPS 除去。

---

## 3. 実装済み機能

### 3.1 API（`:8090`）

| メソッド | パス | 要点 |
| --- | --- | --- |
| GET | `/health` | liveness |
| POST | `/v1/uploads/presign` | `{ fileId, uploadUrl, objectKey }` |
| POST | `/v1/uploads/complete` | body: **`fileId`**, `etag`（etag は現状未検証） |
| GET/DELETE | `/v1/files`、`/v1/files/{id}` | 一覧・メタ・署名 URL・削除 |
| GET | `/v1/quota` | used／limit |
| POST/GET/DELETE | `/v1/folders*` | フォルダ（DELETE は子孫再帰） |
| POST | `/v1/share-links` | TTL 既定 1h・最大 7 日、PW 任意 |
| GET | `/v1/s/{token}`、`.../download` | 公開メタ／302。期限切れ 410、PW 要 401 |
| GET/POST | `/v1/jobs/{id}`、`.../retry` | 状態・failed 再投入 |
| POST | `/internal/v1/jobs/{id}/finish` | processor（`MEDIA_PROCESSOR_TOKEN`） |

**MIME:** jpeg/png/webp/gif、pdf、zip、text/plain。  
**Key:** `user/{sub}/{fileId}/orig`（派生同 prefix）。

### 3.2 Processor

Redis Stream `media:jobs`、sharp で detail（≤1920 WebP）／thumb（320）、上限 20MB・4000×4000。失敗時 DLQ。

### 3.3 UI（`:3004`）

アップロード、フォルダ、クォータ、サムネ、共有リンク、ジョブ再実行。dev: `?user=` + `X-Dev-User-*`。OIDC + OrgSwitcher。

---

## 4. ストレージ・認証・テナント

| 層 | 実装 |
| --- | --- |
| オブジェクト | Garage／任意 S3 互換 |
| メタ | PostgreSQL |
| キュー | Redis Streams |

**認証:** `MEDIA_DEV_AUTH`（development 既定）または OIDC（staging+ で DEV_AUTH 禁止、`org_id` 必須）。

**テナント:** files／folders／share に `org_id`。**クォータは `owner_sub` のみ**（org 非拘束）。`purpose` は任意文字列（ホワイトリスト無し）。

---

## 5. デモ起動

```powershell
copy deploy\.env.example deploy\.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3004 | マイドライブ |
| http://localhost:8090 | API |
| http://localhost:3900 | Garage |

K8s: overlay foundation／collab／commerce／content。例 `http://media.localhost`。staging: [23-media-staging.md](../23-media-staging.md)。

---

## 6. 他 Pxx 契約

| 相手 | 実態 |
| --- | --- |
| **P04** | `MEDIA_API_URL` 時: presign（`purpose=wiki\|chat`）→ PUT → complete → workspace link |
| **P08** | cover UP（`purpose: blog-cover`。設計の `blog` と表記ずれだが API は通る） |
| **P06** | **presign 未使用**。`MEDIA_PUBLIC_BASE` + seed 静的 URL |
| **P01／P02** | OIDC クライアント、Garage、overlay |

---

## 7. 非目標

クライアント E2E 暗号化、動画トランスコード、任意 URL fetch、本番級 CDN／ウイルススキャン、本番 S3→SQS→Lambda（ローカルは Redis worker）、バージョン履歴、OpenAPI。

---

## 8. テスト・ゲート

| 層 | 内容 |
| --- | --- |
| API | `go test ./...`（Compose 中は e2e が Garage 実打、未起動 skip） |
| processor | `npm test` |
| CI | Go＋govulncheck、processor test／audit、Trivy、kustomize、compose config |
| 手動 | サムネ、OIDC、staging で DEV_AUTH 401 |

---

## 9. ギャップ／注意点

| # | 内容 | 深刻度 |
| --- | --- | --- |
| 1 | 本番イベント駆動（S3/SQS/Lambda）未実装 | 対象外(C) |
| 2 | ~~`purpose` 未検証・P08 表記ずれ~~ | **対応済**（whitelist＋blog-cover） |
| 3 | ~~他人ファイル GET が 403~~ | **対応済**（404） |
| 4 | ~~クォータが org 非拘束~~ | **対応済**（org キー） |
| 5 | ~~complete の etag 未検証~~ | **対応済** |
| 6 | ~~共有リンク削除／一覧なし~~ | **対応済**（回数上限は C） |
| 7 | ~~docs の一部が実装と矛盾~~ | **対応済** |
| 8 | P06 は URL シードのみ | 統合浅い |

---

## 10. 根拠パス

- `portfolio-plan/media-platform/DESIGN.md`、`docs/*`
- `pf-media/apps/api/internal/web/server.go`、`service/media.go`、`apps/processor`、`apps/web`
- `pf-media/deploy/compose.yaml`
- 結合: `pf-workspace` upload actions、`pf-content-blog` media upload、`pf-commerce` seed-demo-images
