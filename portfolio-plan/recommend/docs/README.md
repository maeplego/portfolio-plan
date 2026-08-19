# P07 recommend — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P07 recommend |
| 対象スライス | 人気 + item-item、時間 split、registry、jobs similar-items。P06 commerce namespace + overlay C/D 配線済み。events POST は任意 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-recommend` のテストとコード、次に `../DESIGN.md` |

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
| 人気 API + demo-web | 実装済み | 要件、05-api |
| item-item + 時間 split | 実装済み | 設計、テスト |
| コールドスタート fallback | 実装済み | 仕様 |
| ファイル registry | 実装済み。Postgres/MinIO は未接続（計画） | 設計 |
| P06 アダプタ | 実装済み（SKU item_id。events POST 未配線） | |
| P10 配線 | 推論 API + overlay C。未知 ULID は 404 → skill overlap。品質ゲートあり | 05-api |
