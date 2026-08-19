# P12 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P12 reliability-platform |
| 対象スライス | 現行 API + Web。訓練セッションは未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

状態: `triggered` → `acknowledged` → `resolved`。triggered から直接 resolve 可。resolved への ack は 409。ack/resolve の再送は冪等。

Webhook: `X-Signature-256: sha256=<hex>` HMAC-SHA256。`event_id` で再送。解決後の同一 `dedup_key` は新しいインシデント。統合シークレットは API 応答でマスク。

認証: `X-Dev-User-Sub`。P01 は未配線（計画）。
