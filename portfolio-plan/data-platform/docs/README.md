# P13 data-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P13 data-platform |
| 対象スライス | 架空 CSV → 品質ゲート → dbt marts。Metabase と P06/P10 コネクタは計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-data` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書 |
| [02-specification.md](02-specification.md) | 外部仕様書（DAG と KPI） |
| [03-design.md](03-design.md) | 内部設計書 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | 実行契約（HTTP 製品 API は無い） |
| [06-diagrams.md](06-diagrams.md) | 図表 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 架空 CSV DAG + dbt test | 実装済み | 要件、KPI |
| 壊れた CSV で mart 維持 | 実装済み | 仕様、TS |
| Metabase | 計画 | |
| P06 / P10 コネクタ | 計画 | 受け入れに含めない |
