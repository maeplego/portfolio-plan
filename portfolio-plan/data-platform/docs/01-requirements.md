# P13 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P13 data-platform |
| 対象スライス | 受け入れは架空 CSV。本番 DWH 移行は含めない |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

再現可能なバッチで生データ → 品質ゲート → マート。P06/P10 より先に本番パイプライン扱いにしない。Spark / CDC は非目標。

含む: MinIO extract、CSV ゲート、Postgres raw、dbt staging → `marts.daily_sales` / `sales_by_product`、`ops.job_runs`、同一シード再実行で duplication しない。含まない: Metabase（計画）、Great Expectations、P06 JSON コネクタ、PII マート。

受け入れ: DAG 成功、シード KPI が SQL で再現、壊れた CSV で mart が昨日のまま、`job_runs` が failed。
