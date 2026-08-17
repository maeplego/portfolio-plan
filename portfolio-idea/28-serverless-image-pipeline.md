# サーバーレス画像処理パイプライン

アップロードされた画像を、リサイズ・WebP 変換・サムネイル・EXIF 除去まで非同期に処理するパイプラインです。AWS（Lambda, S3, SQS）または Cloudflare Workers / GCS で、クラウドネイティブ力を見せます。16 番がネットワーク中心なら、本アイデアはイベント駆動とコスト最適化です。

## 概要

クライアントは署名付き URL で原画像を S3 へ置き、オブジェクト作成イベントで処理が走り、派生画像が別プレフィックスに出力されます。状態は DynamoDB または Postgres に保存し、フロントで進捗を見ます。

## 就職活動でのアピールポイント

- イベント駆動、リトライ、DLQ
- 大ファイルとメモリ制限（Lambda の制約を設計に織り込む）
- 画像処理のセキュリティ（画像爆弾、不正フォーマット）
- コスト（実行時間、ストレージライフサイクル）
- IaC（SAM / CDK / Terraform）

## 解決する課題

原画像をそのまま配ると遅い・重い・GPS 情報が残る。派生を自動生成し、配信は CDN から行います。

## 想定ユーザー

自作 SNS やブログのメディア基盤。13 番の派生モジュールとしても説明できます。

## 主要機能

### 必須（MVP）

- 署名付きアップロード
- 処理ジョブ（オリジナル検証 → 最大辺 1920 のリサイズ → WebP → 320px サムネ）
- ジョブ状態（queued / processing / succeeded / failed）
- 完了後の表示 URL
- 失敗時の DLQ と手動再実行

### 推奨

- 複数バリエーション（og, list, detail）
- EXIF の Orientation 適用と GPS 除去
- 進捗の SSE またはポーリング
- ウイルススキャン相当は ClamAV は重いので、ファイルタイプ検証とピクセル上限
- CloudFront + OAC
- ライフサイクル（原画像を 30 日後 Glacier、または原画像削除）

### 発展

- Step Functions で複数ステップ可視化
- AVIF、動画は範囲を分けて任意
- 顔モザイクなどは倫理と精度の話が必要で必須ではない

## 画面構成

| 画面 | 役割 |
| --- | --- |
| アップロード | D&D、進捗 |
| ギャラリー | 派生画像 |
| ジョブ詳細 | ログ、再実行 |

## API 概要

- `POST /uploads/presign`
- `GET /jobs/:id`
- `POST /jobs/:id/retry`
- S3 イベント → SQS → worker

## 技術スタック（推奨）

| 層 | 候補 A AWS | 候補 B 軽量 |
| --- | --- | --- |
| アップロード | S3 + presign | R2 + presign |
| キュー | SQS | Cloudflare Queue / 自前 Redis |
| 処理 | Lambda（sharp レイヤー）または ECS タスク（大きい画像） | Worker は CPU 制限があるので Containers |
| 状態 | DynamoDB | Postgres |
| IaC | AWS CDK または Terraform | Terraform |
| フロント | Next.js | 同左 |

Lambda の 512MB〜1GB、タイムアウト 60s で落ちるケースを README に書き、大きい画像は ECS に振る判断ができると評価されます。

## アーキテクチャ

Browser → API (presign) → S3 PUT → EventBridge/S3通知 → SQS → Processor → 派生を S3 → 状態更新 → CDN。Processor は冪等（同じ key の再処理で上書き）。

## データモデル（概要）

- `jobs`（id, s3_key, status, variants[], error, attempts）
- `assets`（job_id, kind, width, height, content_type, size）

## セキュリティ・品質

- マジックバイトで MIME 確認、拡張子だけ信じない
- 解像度・ピクセル数の上限（Decompression bomb 対策）
- バケットは公開せず CDN 経由
- ユーザーごとにプレフィックスを分け、他人のキーを推定しにくくする
- 処理結果の URL に認可が必要なら署名付き GET

## 実装の進め方

1. ローカルで sharp の変換 CLI
2. S3 + 手動 invoke
3. イベント接続と状態 API
4. DLQ、再実行、IaC
5. コスト見積

## 工数目安

- ローカル相当 MVP: 1 週間
- クラウド本番構成: 3 週間

## 面接での話し方

「なぜ同期 API で変換しなかったか（タイムアウト、UX）」「失敗をユーザーにどう見せるか」が中心です。課金アラームを付けた話も実務的です。

## 公開時のチェックリスト

- 対応フォーマットと上限サイズ
- シーケンス図
- 月 1000 枚処理したときの概算コスト
- destroy 手順
