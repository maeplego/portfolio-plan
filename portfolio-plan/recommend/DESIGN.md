# P07 recommend — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/20-recommendation-engine.md`

EC 結合時は `commerce-platform/DESIGN.md`。求人結合時は `talent-platform/DESIGN.md`。

## 対応アイデア

- 20 レコメンドエンジン

## 目的

学習ジョブと低レイテンシ推論を製品として切り出す。P06 の「あなたへのおすすめ」と P10 の「似た求人」が、それぞれ独自の pickle を持たない。ドメイン差は **データセットとアイテムメタデータ** で吸収し、推論 API の形は共通にする。

最初の完成定義は MovieLens（または同等の公開セット）でのオフライン評価まで。EC ログは後からアダプタを足す。

## リポジトリ構成（モノレポ）

学習と推論は別プロセスだが、特徴量とメトリクス定義を共有する。2 リポジトリにするとすぐドリフトする。

```
pf-recommend/
  apps/api          # FastAPI 推論
  apps/train        # バッチ学習 CLI
  apps/demo-web     # ユーザー選択デモ（MovieLens）
  packages/metrics  # Recall@K 等
  packages/schemas  # interaction の契約
  models/           # git-lfs または成果物は MinIO。巨大 npy を Git に置かない
  notebooks/        # 探索のみ。本番経路にしない
```

ポリレポが向くほど学習基盤が大きくなったら `apps/train` を分離してよい。個人ポートフォリオの初期はモノレポ。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| 言語 | Python 3.12+ |
| 推論 | FastAPI, Redis キャッシュ任意 |
| 学習 | pandas, implicit または LightFM、scikit-learn（ベースライン） |
| 実験 | MLflow または `metrics.json` + モデル version 表 |
| 保存 | Postgres（メタ、registry）、成果物は MinIO |
| 評価 | 時間ベース split。ランダム split を完成扱いにしない |

## 設計思想

- **ベースラインを先に公開。** 人気商品に勝てないモデルを載せない
- **リークを設計で防ぐ。** 未来の評価を学習に入れない
- **コールドスタートは仕様。** フォールバックを失敗と偽らない
- **説明可能性は小さく。** 「類似アイテム」まで。深層学習は必須ではない
- **オンライン A/B はトラフィックがないのでやらない。** オフライン比較を成果にする

## 共通 API

- `GET /v1/recommend?namespace=commerce|jobs|movies&user_id=&k=10`
- `GET /v1/similar-items?namespace=&item_id=&k=10`
- `POST /v1/events` `{ namespace, user_id, item_id, type, at }`（任意）
- `GET /v1/models` 現在の version とメトリクス

`namespace` でモデルを切り替える。ユーザー ID 空間は namespace 内で閉じる。P01 の `sub` をそのまま使ってよいが、MovieLens の数値 ID と混ぜない。

## 実装順序

1. ✅ 人気ベース API + demo-web（`pf-recommend` Compose。フィクスチャは `testdata/ml-tiny`）
2. ✅ 協調フィルタ（item-item cosine）と時間 split 評価レポート（`packages/metrics`。ランダム split は未実装）
3. ✅ コールドスタートフォールバック（未知ユーザーは popularity、`fallback: true`）
4. ✅ モデル registry とホットスワップ（`manifest.json` を最後に書くファイル registry。学習中の HTTP train は置かない。Postgres / MinIO は未接続）
5. ✅ P06 アダプタ（BFF `Product.similar` / `recommended` が namespace=commerce の SKU を呼ぶ。失敗時はカタログ順。gateway が paid checkout で events POST 任意配線）
6. ✅ P10 アダプタ（類似求人 API + skill overlap フォールバック。events POST は任意・未配線）

## 実装上の注意点

- 実ユーザーの購買データを Git に置かない
- データセットライセンスを README に書く
- `train` エンドポイントを公開インターネットに置かない
- 推論の p95 を測る。毎回フル行列を読む実装にしない
- 多様性制御は推奨フェーズ

## 他プロジェクトとの契約

P06 は BFF の `Product.similar` とホームの `recommended` から呼ぶ。失敗時・空・未マップ SKU は人気（カタログ順）。item_id は SKU。

P10 は skill overlap フォールバック。CF の overlap 合計がローカル `rankSimilarJobs` より厳密に低ければ出さない。

## デモ

- MovieLens ユーザー切替でリストが変わる
- メトリクス表（人気 vs モデル）
- 新規ユーザーでフォールバックになること

## 非目標

- リアルタイム学習
- 大規模 ANN クラスタ
- 求人・EC・映画を 1 つの埋め込み空間に無理に入れること
