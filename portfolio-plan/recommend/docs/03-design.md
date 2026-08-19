# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン（GitHub: `pf-recommend`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 目的

学習ジョブと低レイテンシ推論を同じリポジトリに置き、特徴量と指標の定義がずれないようにする。推論リクエストの経路でフル評価行列を読まない。

## 2. 含む / 含まない

含む: FastAPI、学習 CLI、指標パッケージ、ファイル registry、架空フィクスチャ（`testdata/ml-tiny` / `jobs-tiny` / `commerce-tiny`）、EC SKU と求人 id の契約テスト。

含まない: implicit / LightFM、Redis、Postgres registry、MinIO、オンライン学習、EC からの events 配線。

## 3. 構成

```
pf-recommend/
  apps/api          FastAPI 推論
  apps/train        バッチ学習 CLI
  apps/demo-web     ユーザー選択デモ（MovieLens 形）
  packages/metrics  時間 split、Recall@K 等
  packages/runtime  リクエスト経路。フル行列を読まない
  packages/schemas  interaction の契約
  testdata/         架空タイトルと SKU。巨大 npy は Git に置かない
```

registry は `manifest.json` を最後に書く。MovieLens 本体は git に置かず、学習時ダウンロードは任意。CI は tiny フィクスチャ。

## 4. 振る舞い（内部）

- namespace ごとに成果物ディレクトリを切る。
- 未知ユーザーは popularity へフォールバックし、失敗とは区別する。
- `commerce` の `item_id` は EC カタログの SKU。ULID ではない。
- `POST /v1/events` は `{namespace}.jsonl` 追記のみ。再学習は人が CLI を回す。

## 5. 他製品との境界

| 相手 | 契約 |
| --- | --- |
| `pf-commerce` BFF | `namespace=commerce`。失敗・空・未マップは BFF がカタログ順（こちらは 404 を必須にしない） |
| `pf-talent-api` | `namespace=jobs`。未知 id は 404 で呼び出し側フォールバック |

## 6. 受け入れ（設計として守ること）

1. 推論が学習成果物の neighbor リストを読む。
2. 未来時刻の評価行が学習に混ざらない。
3. 公開インターネットに学習 HTTP を置かない。
