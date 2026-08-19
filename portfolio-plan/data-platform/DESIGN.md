# P13 data-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/19-etl-data-pipeline.md`

ソース結合時は `commerce-platform/DESIGN.md` および/または `talent-platform/DESIGN.md`。

## 対応アイデア

- 19 ETL / データパイプライン基盤

## 目的

再現可能なバッチで、生データ → 品質ゲート → マート → BI まで通す。最初のソースは架空 CSV でよい。P06 / P10 がエクスポートを出せるようになったらコネクタを足す。パイプラインをアプリより先に「本番」として作らない。

## リポジトリ構成（モノレポ）

個人規模の dbt + DAG は分割すると実行できなくなる。データ基盤は 1 リポジトリが標準的。

```
pf-data/
  orchestrate/     # Dagster または Prefect
  transform/       # dbt-core
  ingest/          # ダウンロード、API 取得、ファイル検証
  seeds/           # 架空 CSV
  bi/              # Metabase の初期ダッシュボード export（任意）
  compose.yaml
```

オーケストレータと dbt をポリレポにすると、同じ日の実行 ID を追うのが苦痛になる。品質テストも dbt 側に置きたい。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| オーケストレーション | Dagster または Prefect |
| 変換 | dbt-core + PostgreSQL |
| レイク相当 | MinIO |
| BI | Metabase |
| 言語 | Python + SQL |
| 品質 | dbt test。必要なら Great Expectations を extract 直後だけ |

Spark はデータ量が見合わないので使わない。README に「規模が伸びたら」と書く。

## 設計思想

- **staging を残す。** 再現とデバッグのため
- **冪等。** 同じ日付を 2 回回して duplication しない
- **品質失敗で mart を中途更新しない。** テーブルスワップまたはトランザクション
- **PII をマートに載せない。** 特に P10 結合後
- **ツール名より DAG の設計を話す**

## 実装順序

1. 手 SQL で mart の形（日次売上、商品別）を決める
2. dbt モデルと test
3. MinIO への extract と Dagster DAG
4. 壊れた CSV で fail するデモ
5. ✅ Metabase は Compose `--profile bi` 任意。最小経路は `bi/dashboards/marts_kpis.sql`（marts のみ）
6. P06 の日次 export コネクタ
7. P10 の非個人集計コネクタ（任意）

## 実装上の注意点

- 資格情報は環境変数
- バックフィル手順を README に書く
- `ops_job_runs` に行数と失敗理由を残す
- BI は `marts` スキーマだけ読む

## 他プロジェクトとの契約

P06: 日付パーティションの `orders_YYYY-MM-DD.json`（個人メールを含めない、user は opaque id）

P10: 職種別の応募数など集計済みのみ。履歴書本文は禁止。

## デモ

- DAG 成功画面
- 壊れたファイルで mart が昨日のまま
- KPI がシードから再現計算できること

## 非目標

- リアルタイム CDC
- 会社の本番 DWH 移行
