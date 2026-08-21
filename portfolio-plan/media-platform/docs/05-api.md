# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | `http://localhost:8090`（Compose） |

OpenAPI ファイルは未作成。認可: `/v1/*` はユーザー。共有 GET はトークン（`X-Share-Password` 任意）。内部 finish は processor トークン。

| メソッド | パス | 用途 |
| --- | --- | --- |
| GET | `/health` | liveness |
| POST | `/v1/uploads/presign` | `{ contentType, size, purpose }`（purpose: `drive`/`wiki`/`chat`/`blog`/`blog-cover`/`product`） |
| POST | `/v1/uploads/complete` | `{ fileId, etag }` |
| GET | `/v1/files` `/v1/files/{id}` | 一覧 / メタ + 派生 URL（他人は 404） |
| DELETE | `/v1/files/{id}` | 削除（他人は 404） |
| GET | `/v1/quota` | 使用量（org キー） |
| GET/POST/DELETE | `/v1/folders` | フォルダ |
| POST | `/v1/share-links` | 共有作成（`password` 任意） |
| GET | `/v1/share-links` | 所有者の共有一覧 |
| DELETE | `/v1/share-links/{token}` | 共有削除（他人は 404） |
| GET | `/v1/s/{token}` `/v1/s/{token}/download` | 公開 |
| GET | `/v1/jobs/{id}` | ジョブ |
| POST | `/v1/jobs/{id}/retry` | 再実行 |
| POST | `/internal/v1/jobs/{id}/finish` | processor |
