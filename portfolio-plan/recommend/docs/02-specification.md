# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン（GitHub: `pf-recommend`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

呼び出し側から見た推論 API と学習の境界。行列の置き方は [03-design.md](03-design.md)。

## 1. 目的

映画・求人・EC で「このユーザー向け」「このアイテムに似たもの」を同じ HTTP 形で返す。ドメイン差は namespace と学習データで吸収し、各製品が独自の学習成果物を持たない。学習用であり、実顧客の購買ログは使わない。

## 2. 含む / 含まない

含む:

- namespace `movies` / `jobs` / `commerce` のオフライン学習（CLI）と推論
- 人気ベースと item-item cosine
- 時間 split のオフライン指標（Recall@K など）
- 未知ユーザーは人気リスト + `fallback: true`
- 未知 item は 404（呼び出し側が自前フォールバックできる）
- EC SKU 契約（`MUG-1` など）。EC BFF（`pf-commerce`）が `item_id` を SKU として写像する
- `POST /v1/events` の JSONL 追記（再学習用。オンライン学習ではない）

含まない:

- リアルタイム学習、公開 HTTP の学習エンドポイント
- 大規模 ANN、Redis キャッシュ、Postgres registry
- ランダム split を完成扱いすること
- 実ユーザー購買の Git 投入
- EC からのクリックイベント配線（API はあるが BFF からは未接続）

## 3. 振る舞い

ユーザー ID 空間は namespace 内で閉じる。MovieLens の数値 ID と EC の購入者 sub を混ぜない。

| 操作 | 仕様 |
| --- | --- |
| `GET /v1/recommend` | 既知ユーザーは item-item 系。未知は人気、`fallback: true`、`model: popularity` |
| `GET /v1/similar-items` | 近傍。クエリの item 自身は出さない。未知 id は 404 `not_found` |
| `GET /v1/models` | version と指標。namespace 一覧 |
| `GET /ready` | 1 namespace 以上ロード済みで 200。空なら 503 |
| `POST /v1/events` | モデルがある namespace へ追記。推論結果は変わらない |
| 学習 | CLI。成果物は neighbor リスト。`manifest.json` を最後に書く |

`k` の既定は 10、最大 50。

EC 側: BFF の `recommended` / `similar` がこの API を呼ぶ。API 失敗時は BFF がカタログ順に戻す（fail-closed）。求人側（`pf-talent-api`）は未知 item の 404 を見て自前ランキングに戻してよい。

## 4. 受け入れ

1. demo-web でユーザーを切替えると推薦リストが変わる。
2. 新規ユーザーは `fallback: true` で人気が出る。
3. `namespace=commerce&item_id=MUG-1` の similar が他 SKU（例: `TEE-1`）を返し、自分は含めない。
4. 未知 item は 404。モデル未ロードの `/ready` は 503。
5. 時間 split により評価用の未来が学習に入らない（ランダム split は未実装のまま）。
