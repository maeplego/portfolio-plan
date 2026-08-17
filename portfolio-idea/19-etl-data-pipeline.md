# ETL / データパイプライン基盤

CSV や API からデータを取り込み、整形し、DWH 相当の Postgres に載せ、ダッシュボードで見るデータエンジニアリング寄りのポートフォリオです。分析基盤志望、バックエンドのバッチ処理志望に向きます。

## 概要

日次で公開データ（例: 気象、為替、OSS の GitHub 統計、架空の売上 CSV）を取り込み、スタースキーマに近い形で蓄積します。Airflow / Dagster / Prefect のいずれかで DAG を可視化します。

## 就職活動でのアピールポイント

- バッチの冪等性、再実行
- スキーマ、データ品質チェック
- ゆっくり変わる次元（SCD）の基礎は任意
- SQL による集計、可視化
- 失敗時の通知とリトライ

## 解決する課題

手元の Excel 更新作業を、再現可能なパイプラインにします。「昨日と同じ結果が再実行で出る」ことが品質です。

## 想定ユーザー

小規模事業の分析担当。デモは「日次売上とチャネル別 LTV 風」など物語を付けます。公開統計データでも構いません。

## 主要機能

### 必須（MVP）

- ソース: ファイル（S3/MinIO）または HTTP API
- ステージングテーブル（生データほぼそのまま）
- 変換ジョブ（型、タイムゾーン、重複排除）
- マート（日次 KPI）
- DAG（extract → validate → transform → load → test）
- 簡易 BI（Metabase / Grafana / Streamlit）

### 推奨

- Great Expectations または dbt test 相当の品質ゲート
- 取り込み時刻、行数、失敗理由のオペレーション表
- パーティション（日付）
- バックフィル手順
- dbt で変換を SQL 化

### 発展

- CDC（過剰になりやすい）
- Spark はデータ量が見合わないと逆効果。量が増えたら、と README に書く

## 画面構成

| 画面 | 役割 |
| --- | --- |
| オーケストレータ UI | DAG 成功/失敗 |
| BI | KPI |
| オペレーション | ジョブ実行履歴（自前テーブルでも可） |

## パイプライン例

1. Extract: 昨日の CSV を MinIO へ（または API を JSON 保存）
2. Validate: 必須列、金額 >= 0、日付パース
3. Load staging
4. Transform: 商品マスタと join、日次売上
5. Test: マートの行数が 0 でない、PK 一意
6. Notify

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| オーケストレーション | Dagster または Prefect（Airflow より個人開発が楽なことが多い） |
| 変換 | Python + dbt-core + Postgres |
| ストレージ | MinIO、PostgreSQL |
| BI | Metabase |
| インフラ | Docker Compose、GitHub Actions で日次相当を手動 trigger |
| 言語 | SQL を厚くするとデータ志望に刺さる |

## アーキテクチャ

Object storage（生データレイク相当）→ staging → warehouse（postgres schema `marts`）。変換は dbt、実行はオーケストレータ。BI は marts のみ読む。

## データモデル（概要）

- `stg_orders`, `stg_items`
- `dim_date`, `dim_product`
- `fct_order_items`
- `ops_job_runs`（started_at, status, row_count）

## セキュリティ・品質

- 資格情報は環境変数
- 個人情報を含む実データを使わない
- 品質失敗で mart を部分更新しない（トランザクションまたはスワップ）

## 実装の進め方

1. 手で SQL して mart の形を決める
2. dbt
3. オーケストレーションと MinIO
4. テストと通知
5. BI ダッシュボード 3 枚

## 工数目安

- MVP: 2 週間
- 推奨: 3〜4 週間

## 面接での話し方

「なぜ staging を残すか（再現とデバッグ）」「冪等（同じ日を 2 回回しても duplication しない）」が核心です。ツール名より設計を話します。

## 公開時のチェックリスト

- サンプル CSV と期待 KPI
- DAG のスクリーンショット
- 失敗させる壊れた CSV とその時の挙動
