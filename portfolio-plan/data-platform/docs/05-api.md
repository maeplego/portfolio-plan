# P13 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P13 data-platform |
| 対象スライス | 製品 HTTP API は無い。実行口と SQL |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | Dagster `http://localhost:3013`、Postgres `localhost:5413` |

| 口 | 用途 |
| --- | --- |
| Compose `pipeline` | 一回実行して exit 0/1 |
| Dagster UI | グラフ表示 |
| `select * from marts.daily_sales` | KPI |
| `ops.job_runs` | 行数と failure_reason |

計画: P06 `orders_YYYY-MM-DD.json` コネクタ。未実装。
