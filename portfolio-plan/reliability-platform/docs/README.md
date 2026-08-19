# P12 reliability-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P12 reliability-platform |
| 対象スライス | インシデント CRUD + HMAC webhook + Postgres + bad-deploy 訓練採点。オンコール・ランブック CRUD は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-reliability` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書 |
| [02-specification.md](02-specification.md) | 外部仕様書 |
| [03-design.md](03-design.md) | 内部設計書 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | API 仕様書 |
| [06-diagrams.md](06-diagrams.md) | 図表 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| インシデント + Ack/Resolve + タイムライン | 実装済み | 要件、状態図 |
| Webhook HMAC + dedup | 実装済み | 仕様、TS |
| 仮想メトリクス表示 | 実装済み（プレビュー） | 画面 |
| オンコール / ランブック CRUD | 計画 | 受け入れに含めない |
| 訓練採点（bad-deploy 1 本） | 実装済み | `POST /v1/training/score`、`/training` |
| overlay F | 実装済み（Postgres `reliability`） | `RELIABILITY_DATABASE_URL`。Compose も Postgres |
