# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | data-platform（GitHub: [pf-data](https://github.com/maeplego/pf-data)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

公開の製品 HTTP API は無い。利用者から見える口は Compose の一回実行、Dagster UI、Postgres の SQL、任意の Metabase である。

## パイプライン

Dagster ジョブ `fictional_csv_sales` は extract → validate → load → dbt。ソースは架空 CSV（MinIO）。`PIPELINE_SOURCE=broken` は負の数量などで validate 失敗し、staging / marts をロードしない。成功時は raw を truncate してフルリフレッシュする（同じシードを二度回しても duplication しない）。

金額は整数円。mart は `marts.daily_sales` と `marts.sales_by_product`。品質失敗で「昨日の mart」を中途更新しない（ゲートが先）。

## BI

Metabase は **Compose の任意プロファイル `bi`**。既定の `up` では起動しない。使うときは `docker compose --profile bi up -d metabase`（ポート 3313）。読むスキーマは `marts`（と健全性の `ops.job_runs`）。ダッシュボードの最小経路は `bi/dashboards/marts_kpis.sql`。計画だけではない。

## まだ無いもの

[pf-commerce](https://github.com/maeplego/pf-commerce) の日付パーティション JSON コネクタ、[pf-talent-api](https://github.com/maeplego/pf-talent-api) の集計コネクタ、Spark / CDC、本番 DWH 移行。
