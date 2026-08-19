# P13 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P13 data-platform |
| 対象スライス | Compose パイプライン。BI は未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

Dagster ジョブ `fictional_csv_sales`: extract → validate → load → dbt。`PIPELINE_SOURCE=broken` は負の数量等で validate 失敗。staging/marts はロードしない。フルリフレッシュ（raw truncate）。日付パーティションの P06 オブジェクトは計画。
