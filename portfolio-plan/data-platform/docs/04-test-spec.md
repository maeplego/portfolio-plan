# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | data-platform（GitHub: [pf-data](https://github.com/maeplego/pf-data)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | ホストは `python -m pytest`。dbt と DAG は Compose。この表と食い違ったらテストかこの文書を直す |

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-D01 | CSV 規則 | 負数・不正日付で失敗。mart を更新しない |
| TS-D02 | 整数円 | 小数を mart に載せない |
| TS-D03 | 粒度 | daily_sales / product が `seeds/expected_kpi.json` と一致 |
| TS-D04 | 再実行 | 同一シードで duplication しない |
| TS-D05 | job_runs | 失敗時は failed と reason |

未自動化: Metabase 画面のクリック操作。プロファイル `bi` の起動確認は手動でよい。
