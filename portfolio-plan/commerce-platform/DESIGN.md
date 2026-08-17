# P06 commerce-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/05-ecommerce-order-microservices.md`
- `portfolio-idea/06-realtime-inventory-dashboard.md`
- `portfolio-idea/24-graphql-bff.md`
- `portfolio-idea/25-event-sourcing-orders.md`

K8s 化では `cloud-platform/DESIGN.md`。商品画像は `media-platform/DESIGN.md`。推薦接続は `recommend/DESIGN.md`。

## 対応アイデア

- 05 マイクロサービス型 EC 注文
- 06 リアルタイム在庫ダッシュボード
- 24 GraphQL BFF
- 25 イベントソーシング注文処理

## 目的

小さな D2C の注文から出荷までを、**分割しすぎないマイクロサービス** で実装する。購入者 UI は GraphQL BFF、倉庫 UI は REST + WebSocket、注文の正はイベントストリーム。これがポートフォリオのバックエンド本線。

最初から 8 サービスに切らない。モノリスで注文フローを正しくしてから抽出する（アイデア 05 の注意を遵守）。

## リポジトリ構成（ポリレポ）

サービスごとに DB とデプロイが独立する前提なのでポリレポ。共有ライブラリは薄く（CloudEvents、auth middleware）。共有ライブラリを厚くするとモノリスの分割にしかならない。

| リポジトリ | 役割 | アイデア |
| --- | --- | --- |
| `pf-commerce-catalog` | 商品マスタ | 05 |
| `pf-commerce-inventory` | 在庫残高、移動、引当 | 05, 06 |
| `pf-commerce-ops-web` | 在庫ダッシュボード、出荷 | 06 |
| `pf-commerce-cart` | カート。Redis でも Postgres でも可 | 05 |
| `pf-commerce-order` | コマンド、イベントストア、投影 | 05, 25 |
| `pf-commerce-payment` | 決済モック、冪等キー | 05 |
| `pf-commerce-notify` | メール | 05 |
| `pf-commerce-bff` | GraphQL。購入者画面専用 | 24 |
| `pf-commerce-storefront` | 購入者 Next.js | 24 |
| `pf-commerce-gateway` | 公開入口、JWT、レート制限。BFF と ops を振り分け | 05 |
| `pf-commerce-infra` | Compose、後に P02 の kustomize overlay | 05, 17 |

`pf-commerce-order` に支払いや在庫を戻さない。補償はイベントで行う。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| サービス | Go + PostgreSQL（サービスごとスキーマまたはコンテナ） |
| メッセージ | RabbitMQ。初期 Kafka 禁止 |
| BFF | TypeScript, GraphQL Yoga または Apollo、DataLoader |
| Storefront / Ops | Next.js |
| 決済 | 完全モック。Stripe テストモードは任意。本物のカード禁止 |
| 観測 | P02 の OTLP |
| 画像 | P03。未完成時は URL 文字列のみ |

## 設計思想

- **同期は読み取りと、短いコマンド。** チェックアウトのオーケストレーションは order がプロセスマネージャ
- **在庫と注文は別ライフサイクル。** だからサービスが分かれる
- **注文は上書きしない。** イベントを append し、一覧は投影
- **BFF は購入者の画面集約だけ。** 倉庫オペレーションに GraphQL を無理に被せない
- **N+1 を測ってから DataLoader を誇る**

## サービス内のイベントソーシング（25）

対象は **注文集約だけ**。商品マスタまでイベントソーシングしない。

コマンド例: `CreateOrder`, `ReserveInventory`（結果イベントを受けて続行）, `RecordPayment`, `CancelOrder`, `ShipOrder`

不正遷移は拒否。投影 `order_list_view` を BFF とストアフロントが読む。管理画面にイベントタイムラインを出す。

## 在庫（06）

`stock_movements` が正、`stock_balances` はトランザクション内更新。引当は `reservations` + TTL。ダッシュボードは cursor ページングと Redis Pub/Sub。

## GraphQL（24）

下位 REST: catalog, inventory, reviews（reviews は catalog 内でも可。サービスを増やしすぎない）。`Product.inventory` と `reviews` は DataLoader。クエリコスト上限を付ける。

## 実装順序

1. **モジュラモノリス**（1 リポジトリ一時でも可）で購入〜在庫不足までテスト
2. catalog / inventory / order を抽出。決済はまだ order 内モックでも可
3. 注文をイベントストア化（テスト: Given/When/Then）
4. payment と notify を抽出。outbox
5. ops-web のグリッドとライブ更新
6. BFF + storefront。DataLoader なしのトレースを残してから導入
7. P03 画像、P07 推薦スロット、P02 kind

## 実装上の注意点

- チェックアウト冪等キー。連打で二重引当しない
- 予約 TTL 切れと支払い成功の競合を文書化する
- GraphQL の生 ID をメトリクスラベルにしない
- マイクロサービス初期の分散トランザクションに 2PC を使わない
- 「全部を分割する必要はない」を README に自分の言葉で書く
- 決済は PCI 対象外（カード番号を受け取らない）

## 他プロジェクトとの契約

- P01: 購入者と ops でロールを分ける。ops は workspace とは別クライアントでも可
- P07: `GET` 互換の `userId` / `itemId`。クリックイベントは任意
- P13: 日次で `orders` 投影のエクスポート（CSV/JSON）を MinIO へ
- P12: 在庫サービスを止める障害を訓練シナリオにできるが、P12 から本番コマンドは叩かない

## デモ

- 在庫 1 の商品を 2 人が同時に買う → 1 成功 1 補償
- Jaeger で BFF → 3 REST が 1 トレース
- 注文タイムラインに PaymentFailed が見える
- ops-web の 2 画面で入庫が流れる

## 非目標

- マーケットプレイス（複数出品者）
- 本格決済・会計
- Kafka クラスタ
