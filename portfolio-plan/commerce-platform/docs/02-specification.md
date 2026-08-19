# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | EC コマース（GitHub: `pf-commerce`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

購入者と運用画面、公開 REST、購入者向け GraphQL から見た振る舞い。プロセス内のトランザクションは [03-design.md](03-design.md)。

## 1. 目的

小さな直販ショップで、商品を見てカートから支払いまで進み、在庫が足りないときは失敗が分かるようにする。金額は整数、決済はカード番号を受け取らないモック、同時購入では在庫 1 に対して成功は 1 件だけ、という契約を外から固定する。

## 2. 含む / 含まない

含む: 公開カタログ、カート、冪等つきチェックアウト、在庫不足と決済失敗、注文の参照と出荷、運用の商品作成・入庫・在庫グリッドと SSE、通知ログ、GraphQL BFF、推薦スロット（失敗時はカタログ順）、Compose と Kubernetes 連携デモの commerce 構成。

含まない: 実カード、本番 SMTP、RabbitMQ / Redis、ID 基盤（`pf-identity`）のログイン画面、メディア基盤（`pf-media`）の実画像パイプライン、レート制限、マーケットプレイス。

## 3. 用語

| 用語 | 意味 |
| --- | --- |
| 最小通貨単位 | JPY なら円。JSON は `priceMinor`（整数） |
| 利用可能数 | on-hand − 引当中。一覧の `availableQty` |
| 引当 | チェックアウト開始で押さえる予約。TTL 15 分 |
| 補償 | 不足または決済失敗で引当を戻す |
| 冪等キー | 購入者スコープ。再試行用。注文の二重作成を防ぐ |
| fail-closed | 推薦 API（`pf-recommend`）が落ちる・空・SKU 未対応のとき、GraphQL はエラーにせずカタログ一覧順を返す |

## 4. 金額と時刻

1. 金額は整数のみ。`12.5` のような JSON 数値は 4xx。
2. 通貨は 3 文字。シードは `JPY`。
3. API の時刻は UTC Instant（`2006-01-02T15:04:05Z` 形式）。DB は `timestamptz`。

## 5. 公開（認証なし）

| 操作 | 仕様 |
| --- | --- |
| 商品一覧 | シード 3 SKU（`MUG-1`, `TEE-1`, `STK-1`）。各行に `availableQty` |
| 商品詳細 | ULID。無ければ 404 |

## 6. 購入者

開発: `X-Dev-User-Sub`。`X-Dev-Role` 省略時は `buyer`。ヘッダ無しのカート/チェックアウトは 401。

| 操作 | 仕様 |
| --- | --- |
| カート取得・追加・置換 | 自分の sub だけ |
| チェックアウト | 本文 `lines` またはカート。`Idempotency-Key` ヘッダまたは `idempotencyKey` |
| 成功 | 新規 201 `paid`。再送 200 で同じ注文 ID |
| 在庫不足 | 409。本文に `error.code=inventory_shortage` と cancelled 注文 |
| 注文取得 | 自分の ID だけ。他人は 403 |

数量 0 以下、存在しない商品、空カートは 400。

## 7. 運用（ops）

`X-Dev-Role: ops`。購入者の入庫は 403。商品作成と入庫は 201。

## 8. 決済と通知

別プロセス `apps/payment`。リクエストに PAN / CVV を置かない。成功時 `paymentId`（ULID）だけが注文に残る。失敗注入は `POST /v1/test/fail-next`（テスト用）。

支払い確定とキャンセルは order の outbox から notify へ。notify は SMTP を送らずメッセージログを持つ。

## 9. 画面

| 画面 | 仕様 |
| --- | --- |
| `/` | カタログ。ブラウザから REST |
| `/products/:id` | 1 点チェックアウト。BFF があれば在庫・レビュー・類似商品を GraphQL |
| `/demo` | buyer-a / buyer-b の 2 ペイン。`MUG-1` を同時購入 |
| ops-web `:3010` | 在庫グリッド、入庫、SSE フィード、notify 一覧 |

ID 基盤のログイン画面は未実装。ユーザー切替は開発ヘッダ。SSE は `devUser` / `devRole` クエリ（EventSource がカスタムヘッダを付けられないため）。

## 10. GraphQL（BFF `:8110`）

`POST /graphql`。クエリ `products` / `product(id)` / `recommended(userId, k)`。ネスト `inventory { availableQty }`、`reviews`、`similar(k)`。REST gateway は公開契約として残す。クエリ文字列が長すぎると `query too expensive`。

`recommended` と `Product.similar` は推薦 API の `namespace=commerce` を呼ぶ。item は SKU（`MUG-1` など）。失敗・空・カタログに無い SKU は `source: "popularity"` と `fallback: true` でカタログ順。

## 11. Kubernetes 連携デモ

commerce 構成（kustomize `portfolio-integration-d-commerce`）には catalog / inventory / order / payment / notify / gateway / BFF / storefront / ops-web と `pf-recommend` が含まれる。開発者ポータル・信頼性訓練・データ基盤はこの構成には載せない。

## 12. 既知の制限

レート制限なし。RabbitMQ / Redis なし。購入者から見える REST は gateway、GraphQL は BFF。

## 13. 受け入れ（外から見えること）

1. 一覧の価格が整数で、`MUG-1` の初期利用可能数が 1。
2. 在庫のある 1 点チェックアウトが `paid`。同じ冪等キーの再送は 200 で追加減算しない。
3. 在庫 1 に数量 2、または同時 2 リクエストは 201 と 409 に分かれ、確定は 1 件。
4. 決済モック失敗では cancelled と在庫復元。notify に対応ログが残る。
5. 推薦 API 停止時も GraphQL `recommended` は 200 相当でカタログ順を返す。
