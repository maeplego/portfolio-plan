# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | reliability-platform（GitHub: [pf-reliability](https://github.com/maeplego/pf-reliability)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。機械可読は `packages/openapi` |
| 基準 | `http://localhost:8012`（Compose） |

開発書き込み: `X-Dev-User-Sub`。Webhook: `X-Signature-256`。

| メソッド | パス | 認可 | 用途 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | なし | 生存。ready は Postgres ping |
| GET | `/v1/services` `/v1/services/{id}` | なし | 監視対象マスタ |
| GET | `/v1/virtual-metrics` | なし | 訓練用の仮想時系列 |
| GET | `/v1/incidents` `/v1/incidents/{id}` | なし | 一覧と詳細 |
| POST | `/v1/incidents` | 開発ヘッダ | 手動起票 |
| POST | `/v1/incidents/{id}/ack` | 同上 | acknowledged |
| POST | `/v1/incidents/{id}/resolve` | 同上 | resolved |
| POST | `/v1/incidents/{id}/comments` | 同上 | タイムライン |
| POST | `/v1/demo/alerts` | 同上 | 擬似 5xx で起票デモ |
| POST | `/v1/integrations/{key}/events` | HMAC | 外部からのイベント |
| POST | `/v1/training/score` | なし | `{ actions }` を採点。未知操作は 400 |

未実装: ランブック CRUD、訓練セッション履歴、オンコール週次。
