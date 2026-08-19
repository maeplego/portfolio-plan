# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | data-platform（GitHub: [pf-data](https://github.com/maeplego/pf-data)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | Dagster `http://localhost:3013`、Postgres `localhost:5413`、Metabase（任意）`http://localhost:3313` |

製品向け REST は無い。実行口は次のとおり。

| 口 | 用途 |
| --- | --- |
| Compose サービス `pipeline` | 一回実行して exit 0/1 |
| Dagster UI | ジョブグラフと実行 |
| `select * from marts.daily_sales` など | KPI |
| `ops.job_runs` | 行数と failure_reason |
| Compose `--profile bi` の Metabase | marts の閲覧。既定では起動しない |

未実装: [pf-commerce](https://github.com/maeplego/pf-commerce) の `orders_YYYY-MM-DD.json` コネクタ。
