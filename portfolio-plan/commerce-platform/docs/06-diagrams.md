# P06 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | シーケンスはスライス 6。overlay D は P06 サブセット（新サービス未搭載） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 記法 | Mermaid。ユースケースは UML 楕円の代替としてフロー |

## 1. ユースケース

```mermaid
flowchart LR
  subgraph actors [アクター]
    Buyer[購入者]
    Ops[ops]
  end
  subgraph uc [P06 スライス2]
    UC1[商品を見る]
    UC2[カートに入れる]
    UC3[チェックアウトする]
    UC4[在庫不足を知る]
    UC5[入庫する]
  end
  Buyer --> UC1
  Buyer --> UC2
  Buyer --> UC3
  Buyer --> UC4
  Ops --> UC5
  UC3 --> UC4
```

## 2. 画面遷移

```mermaid
flowchart TB
  C[カタログ /]
  P[商品 /products/id]
  D[デモ /demo]
  C --> P
  C --> D
  P --> Paid[paid]
  P --> Short[inventory_shortage]
  D --> Paid
  D --> Short
```

## 3. 成功時シーケンス

```mermaid
sequenceDiagram
  actor Buyer
  participant GW as gateway
  participant Ord as order
  participant Inv as inventory
  participant Pay as payment
  participant Ntf as notify
  Buyer->>GW: POST /v1/checkout + Idempotency-Key
  GW->>Ord: POST /v1/checkout
  Ord->>Inv: Reserve (1 TX)
  Inv-->>Ord: held
  Ord->>Pay: Charge(no PAN)
  Pay-->>Ord: paymentId
  Ord->>Inv: Consume
  Note over Ord: outbox OrderPaid（同一 TX）
  Ord-->>GW: 201 paid
  GW-->>Buyer: 201 paid
  Ord->>Ntf: POST notification
```

## 4. 在庫不足（同時 2 人）

```mermaid
sequenceDiagram
  actor A
  actor B
  participant GW as gateway
  participant Ord as order
  participant Inv as inventory
  A->>GW: checkout qty 1
  B->>GW: checkout qty 1
  GW->>Ord: checkout A
  GW->>Ord: checkout B
  Ord->>Inv: ReserveHeld A
  Inv-->>Ord: ok reserved=1
  Ord->>Inv: ReserveHeld B
  Inv-->>Ord: shortage
  Ord-->>GW: 201 paid
  Ord-->>GW: 409 inventory_shortage
  GW-->>A: 201 paid
  GW-->>B: 409 inventory_shortage
  Note over Inv: B の補償は held が無いので no-op
```

在庫 1 に数量 2 の単独リクエストでは、Reserve が shortage のあと `ReleaseOrder` が空の held を見る。残高は UPDATE が 0 行なので減っていない。

## 5. 注文状態

```mermaid
stateDiagram-v2
  [*] --> pending: Create
  pending --> paid: PaymentRecorded
  pending --> cancelled: OrderCancelled
  paid --> shipped: OrderShipped
  shipped --> [*]
  cancelled --> [*]
```

`Ship` は paid 以外を拒否。決済モックはカードを持たない。

## 6. ER（論理）

```mermaid
erDiagram
  catalog_products ||--o{ inventory_stock_balances : "product_id 論理"
  inventory_sites ||--o{ inventory_stock_balances : site
  inventory_stock_balances ||--o{ inventory_stock_movements : history
  inventory_reservations }o--|| commerce_orders : order_id 論理
  commerce_orders ||--|{ commerce_order_lines : lines
  commerce_order_events }o--|| commerce_orders : stream_id
  commerce_outbox }o--|| commerce_orders : aggregate_id
  catalog_reviews }o--|| catalog_products : product_id
  cart_items }o--|| catalog_products : product_id 論理
```

物理 FK は張っていない。プロセスごとに別 DB。列は各 `schema.sql` を正とする。
