# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | データ基盤 [pf-data](https://github.com/maeplego/pf-data) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

再現可能なバッチで、生データ → 品質ゲート → マート → BI まで通す。最初のソースは架空 CSV でよい。EC [pf-commerce](https://github.com/maeplego/pf-commerce) や求人 [pf-talent-api](https://github.com/maeplego/pf-talent-api) の本番エクスポートを、パイプラインより先に「本番ソース」として扱わない。

学習用であり、Spark / CDC / 商用 DWH の置き換えではない。公開の製品 HTTP API は無い。

## 2. 含む

- MinIO への extract、CSV 品質ゲート、Postgres raw
- dbt staging → `marts.daily_sales` / `marts.sales_by_product`
- `ops.job_runs`（行数と失敗理由）
- 同一シード再実行で duplication しない（成功時は raw を truncate してフルリフレッシュ）
- 壊れた CSV で validate 失敗し、staging / marts をロードしない
- Metabase は Compose `--profile bi` の任意サービス。既定の `up` では起動しない。最小経路は `bi/dashboards/marts_kpis.sql`

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| Great Expectations | dbt test で足りる |
| EC / 求人の本番 JSON コネクタ | 未実装。架空 CSV が正 |
| PII マート、履歴書本文 | 禁止 |
| Spark / CDC / 本番 DWH 移行 | 規模が見合わない |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| データ開発者 | DAG を回し SQL で KPI を確認する | ローカル Compose |
| BI 閲覧者 | marts だけを読む | Metabase（任意プロファイル） |

## 5. 前提

- オーケストレーションは Dagster。変換は dbt-core + PostgreSQL。レイク相当は MinIO
- 金額は整数円
- BI が読むスキーマは `marts`（健全性で `ops.job_runs`）
- 資格情報は環境変数。実顧客データは使わない

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | DAG `fictional_csv_sales` が extract → validate → load → dbt を順に回す | 再現可能なバッチ |
| FR-02 | 同じシードを二度回しても duplication しない | 冪等 |
| FR-03 | 壊れた CSV はゲートで失敗し、昨日の mart を中途更新しない | 品質失敗で壊さない |
| FR-04 | `ops.job_runs` に成功/失敗が残る | 運用の痕跡 |
| FR-05 | シード KPI が SQL で再現できる | マートの形 |
| FR-06 | Metabase は `--profile bi` で起動できる。既定 compose には必須にしない | 任意 BI |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | PII をマートに載せない | 特に求人結合後 |
| NFR-02 | README に学習用であることとバックフィルを書く | 誤用 |
| NFR-03 | Spark を使わない旨を README に書く | 規模 |

## 8. 受け入れ

1. DAG が成功し、シード KPI が SQL で再現できる
2. 壊れた CSV で mart が昨日のまま、`job_runs` が failed
3. 同一シード再実行で行が増えない
4. `docker compose --profile bi up -d metabase` で Metabase が上がる（任意）
