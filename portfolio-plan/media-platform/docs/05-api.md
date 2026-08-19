# P03 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P03 media-platform |
| 対象スライス | 現行 HTTP。OpenAPI は未作成 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8090` |

認可: `/v1/*` はユーザー。共有 GET はトークン。内部 finish は processor トークン。

| メソッド | パス | 用途 |
| --- | --- | --- |
| GET | `/health` | liveness |
| POST | `/v1/uploads/presign` | `{ contentType, size, purpose }` |
| POST | `/v1/uploads/complete` | `{ key, etag }` |
| GET | `/v1/files` `/v1/files/{id}` | 一覧 / メタ + 派生 URL |
| DELETE | `/v1/files/{id}` | 削除 |
| GET | `/v1/quota` | 使用量 |
| GET/POST/DELETE | `/v1/folders` | フォルダ |
| POST | `/v1/share-links` | 共有 |
| GET | `/v1/s/{token}` `/v1/s/{token}/download` | 公開 |
| GET | `/v1/jobs/{id}` | ジョブ |
| POST | `/v1/jobs/{id}/retry` | 再実行 |
| POST | `/internal/v1/jobs/{id}/finish` | processor |
