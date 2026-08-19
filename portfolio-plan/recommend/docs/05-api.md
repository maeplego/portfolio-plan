# P07 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P07 recommend |
| 対象スライス | 現行 HTTP。機械可読は FastAPI `/docs` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8098` |

| メソッド | パス | 用途 | 主な状態 |
| --- | --- | --- | --- |
| GET | `/health` | liveness | 200 `{ "ok": true }` |
| GET | `/ready` | モデル有無 | 200 / 503 |
| GET | `/v1/recommend?namespace=&user_id=&k=` | ユーザー向け | 200。k 既定 10 最大 50 |
| GET | `/v1/similar-items?namespace=&item_id=&k=` | 類似 | 200 / 404 |
| GET | `/v1/models` | version と Recall@K 等 | 200 |
| POST | `/v1/events` | 追記 | 2xx。オンライン学習しない |
