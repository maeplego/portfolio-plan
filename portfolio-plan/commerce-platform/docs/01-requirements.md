# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | EC コマース [pf-commerce](https://github.com/maeplego/pf-commerce) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

小さな D2C が注文を増やすとき、在庫と注文はライフサイクルが違う。同じ行を上書きする巨大 CRUD だと「なぜ欠品したか」「同時に二人買ったら誰が勝つか」を説明できない。注文から出荷までの本線として、境界をモジュールで正し、プロセスに分ける。

学習用であり、商用 EC や PCI 決済の置き換えではない。本物のカード番号は受け取らない。

## 2. 含む

- 商品一覧・詳細（価格は整数の最小通貨単位、画像は URL 文字列）
- カートとチェックアウト（冪等キー必須）
- 在庫引当 → 決済モック（別プロセス） → 確定。不足なら失敗と引当解除
- 在庫 1 を二人同時に買ったとき、成功は 1 件だけ
- 購入者は自分の注文だけ読める
- catalog / inventory / order / payment / notify / bff / ops-web を別プロセス。同一 `pf-commerce` の `apps/`
- 注文イベントストア + 決済成功/失敗の outbox → notify（SMTP なし、プロセス内ログ）
- ops-web の在庫グリッドと SSE ライブ更新（Redis なし）
- 購入者 GraphQL BFF。`Product.inventory` と `reviews` をバッチ取得。REST gateway は残す
- 推薦 [pf-recommend](https://github.com/maeplego/pf-recommend) の `recommended` / `similar`。失敗・空・未マップ SKU はカタログ順（fail-closed）
- 単体 Compose。Kubernetes overlay D は payment / notify / BFF / ops-web と推薦 API を含む

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| 8 git リポジトリ | 抽出が大きすぎるのでプロセス分割に留める |
| overlay D への開発者ポータル / 信頼性 / データ基盤 | いまの D は EC フルと推薦まで |
| RabbitMQ / 実メール / Redis | outbox ポーリングとプロセス内 SSE |
| 認証基盤のログイン画面 | 開発ヘッダで開始 |
| メディア基盤の実画像 | URL 文字列 |
| マーケットプレイス、本格決済、Kafka | 範囲外 |
| クリック events の BFF 配線 | 推薦 API の POST はあるが未接続 |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| 購入者 | カタログを見てチェックアウトする | `X-Dev-User-Sub` + 役割 `buyer`（省略時） |
| ops | 商品登録・入庫 | `X-Dev-User-Sub` + `X-Dev-Role: ops` |
| システム | 引当と補償の正 | — |

## 5. 前提

- ID は ULID。金額は整数。DB 時刻は `timestamptz`（UTC）
- 決済モックはカード番号フィールドを持たない
- 負在庫は拒否
- サービスは別プロセス・別 DB。共有は薄い packages（整数金額、ULID、dev auth）

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 公開で商品一覧・詳細を取れる。価格は `priceMinor` + `currency` | 浮動小数で金を表さない |
| FR-02 | チェックアウトは冪等キー必須。同一購入者・同一キーは追加引当しない | 連打で二重引当しない |
| FR-03 | 引当は利用可能数（on-hand − reserved）に対して原子的 | 同時購入の正 |
| FR-04 | 不足時は注文を cancelled（`inventory_shortage`）にし、取れた引当を戻す | 補償 |
| FR-05 | 決済モック成功後に引当を消費し `paid` | 注文と在庫のライフサイクルを分ける |
| FR-06 | 決済モック失敗時も引当を戻し `payment_failed` | 同じ補償の型 |
| FR-07 | 購入者は他人の注文を読めない | 認可はサーバ |
| FR-09 | 決済は payment プロセス。カード番号フィールドなし。冪等キーで再課金しない | PCI 対象外 |
| FR-10 | 支払い確定・キャンセルは order の outbox 経由で notify に届く。同じ outbox id は二重送信しない | イベントとメールの結合 |
| FR-11 | ops は在庫グリッドを cursor で読め、入庫が SSE で行に反映される | 倉庫 UI |
| FR-12 | 購入者 BFF は商品の在庫とレビューを 1 GraphQL クエリで取れる。DataLoader で N+1 を潰す | 画面集約 |
| FR-13 | 推薦失敗時も GraphQL はエラーにせずカタログ順を返す（`fallback: true`） | 推薦停止で購入を止めない |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | 純論理と httptest は DB なしで緑 | CI が Docker 無しでも回帰する |
| NFR-02 | Compose は専用 Postgres（DB 分割）。連携は overlay D | 12GB で 1 overlay |
| NFR-03 | README に学習用である旨を書く | 本番誤用 |
| NFR-04 | ログと API にカード番号を出さない | PCI 対象外を守る |

## 8. 受け入れ

1. 商品一覧の価格が整数で、`MUG-1` の初期在庫が 1
2. 在庫のある 1 点チェックアウトが `paid`、在庫が 1 減る
3. 在庫 1 に対する数量 2 が `inventory_shortage` で、在庫が減らない
4. 同時 2 チェックアウトが 201 と 409 に分かれ、確定は 1 件、残り在庫 0
5. 同じ冪等キーの再送が 200 で、追加引当しない
6. `docker compose up` で storefront の `/demo` が同じ物語を見せる（公開口は gateway）
7. catalog / inventory / order / payment / notify が別プロセスであり、8 リポジトリではない
8. overlay D の gateway で同時 checkout が 201 と 409 に分かれる（任意の連携デモ）
9. 支払い成功で notify に `OrderPaid` が 1 件残る（outbox 再送で増えない）
10. ops-web が在庫行を表示し、入庫 API がグリッド契約を返す
11. BFF で複数商品の `inventory` を取るとき REST `/v1/available` は 1 回
12. 推薦 API 停止時も `recommended` はカタログ順で返る
