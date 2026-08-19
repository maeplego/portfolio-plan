# P12 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P12 reliability-platform |
| 対象スライス | 現行 HTTP。OpenAPI は `packages/openapi` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8012` |

| メソッド | パス | 認可 | 用途 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | なし | 生存 |
| GET | `/v1/services` `/v1/services/{id}` | なし | マスタ |
| GET | `/v1/virtual-metrics` | なし | 仮想 |
| GET | `/v1/incidents` `/v1/incidents/{id}` | なし | 一覧 |
| POST | `/v1/incidents` | X-Dev-User-Sub | 手動起票 |
| POST | `/v1/incidents/{id}/ack` | 同上 | ack |
| POST | `/v1/incidents/{id}/resolve` | 同上 | resolve |
| POST | `/v1/incidents/{id}/comments` | 同上 | タイムライン |
| POST | `/v1/demo/alerts` | 同上 | 擬似 5xx |
| POST | `/v1/integrations/{key}/events` | HMAC | ingest |

計画: ランブック CRUD、訓練セッション。
