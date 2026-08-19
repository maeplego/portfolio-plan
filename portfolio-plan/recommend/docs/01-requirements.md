# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン [pf-recommend](https://github.com/maeplego/pf-recommend) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

EC の「あなたへのおすすめ」と求人の「似た求人」がそれぞれ独自の学習成果物を持つと、リーク対策とメトリクス定義が二重になる。学習ジョブと低レイテンシ推論を 1 製品に切り出す。ドメイン差は namespace とデータセットで吸収し、HTTP の形は共通にする。

学習用である。実ユーザーの購買ログは Git に置かない。完成の基準は MovieLens 形フィクスチャでのオフライン評価まで。

## 2. 含む

- namespace `movies` / `jobs` / `commerce` のオフライン学習（CLI）と推論 API
- 人気ベースと item-item cosine
- 時間 split のオフライン指標（Recall@K など）
- 未知ユーザーは人気リスト + `fallback: true`
- `GET /v1/similar-items`。未知 item は 404（呼び出し側が自前フォールバックできる）
- EC [pf-commerce](https://github.com/maeplego/pf-commerce) の BFF が SKU（`MUG-1` など）で呼ぶ。失敗時はカタログ順
- 求人 [pf-talent-api](https://github.com/maeplego/pf-talent-api) は `namespace=jobs`。品質がローカル順位より劣るときはスキル重なりへ閉じる
- demo-web（ユーザー切替）
- `POST /v1/events` の JSONL 追記（再学習用。オンライン学習ではない）

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| リアルタイム学習、公開 HTTP の学習エンドポイント | 学習は CLI。公開 train は置かない |
| 大規模 ANN、Redis キャッシュ、Postgres registry | 未接続 |
| ランダム split を完成扱いすること | 時間 split が正 |
| 実顧客購買の Git 投入 | プライバシー |
| EC からのクリックイベント配線 | API はあるが BFF からは未接続 |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| 推論の呼び出し側 | EC BFF、求人 API、demo-web | 開発用。公開インターネットに train を置かない |
| 学習オペレーター | CLI でモデルを出す人 | ローカル |
| デモ利用者 | MovieLens 形のユーザー切替 | なし |

## 5. 前提

- フィクスチャは `testdata/ml-tiny`。巨大 npy は Git に置かない
- ユーザー ID 空間は namespace 内で閉じる。MovieLens の数値 ID と購入者 `sub` を混ぜない
- 単体 Compose で API と demo-web が動く
- データセットライセンスを README に書く

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | `GET /v1/recommend` が namespace と user_id と k でリストを返す | 共通推論口 |
| FR-02 | 人気ベースを先に出し、協調フィルタは時間 split で評価する | ベースラインに勝てないモデルを載せない |
| FR-03 | 未知ユーザーは popularity と `fallback: true` | コールドスタートを失敗と偽らない |
| FR-04 | `GET /v1/similar-items` の未知 item は 404 | 呼び出し側が閉じ方を選べる |
| FR-05 | 未来の評価を学習に入れない | リーク |
| FR-06 | ユーザー切替でリストが変わる（demo-web） | 協調の見え方 |
| FR-07 | EC の item_id は SKU。失敗時は呼び出し側がカタログ順へ戻す | 購入フローを止めない |
| FR-08 | 求人側は推薦品質がローカル順位より劣るときスキル重なりへ閉じる | 検索本体を壊さない |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | 実ユーザー購買を Git に置かない | プライバシー |
| NFR-02 | 公開 HTTP train を置かない | 学習経路の保護 |
| NFR-03 | 毎回フル行列を読む実装にしない | 推論レイテンシ |
| NFR-04 | README に学習用であることとライセンスを書く | 誤用 |

## 8. 受け入れ

1. demo-web でユーザーを切り替えるとリストが変わる
2. 時間 split のメトリクス表が出せる
3. 新規ユーザーが `fallback: true` の人気リストになる
4. 未知 item の similar-items が 404
5. EC BFF が推薦停止でも `recommended` をカタログ順で返す
6. 求人の similar は推薦失敗または品質不足でスキル重なりに閉じる
