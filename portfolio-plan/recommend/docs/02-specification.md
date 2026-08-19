# P07 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P07 recommend |
| 対象スライス | 現行 FastAPI。オンライン学習は未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

namespace でモデルを切る（`movies` / `jobs`。commerce は計画）。ユーザー ID 空間は namespace 内。未知ユーザーは人気、`fallback: true`。未知 item は 404。`/ready` は 1 namespace 以上ロード済みで 200、否則 503。`POST /v1/events` は JSONL 追記のみ。再学習は CLI。公開 `/admin/train` は無い。
