# P13 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P13 data-platform |
| 対象スライス | dbt-core + Dagster + Postgres + MinIO |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

整数円。mart 粒度は `transform/manual/mart_shape.sql` と pytest/DuckDB が一致。dbt mart テスト失敗時のテーブルスワップは未実装。CSV ゲートが昨日の mart を守る。BI は marts スキーマだけ読む（計画）。
