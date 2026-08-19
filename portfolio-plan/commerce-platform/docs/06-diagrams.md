# P06 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | シーケンス・状態・ER はスライス 2。画面は実装済み。overlay D は計画 |
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
  participant Pay as payment mock
  Buyer->>GW: POST /v1/checkout + Idempotency-Key
  GW->>Ord: POST /v1/checkout
  Ord->>Inv: Reserve (1 TX)
  Inv-->>Ord: held
  Ord->>Pay: Charge(no PAN)
  Pay-->>Ord: paymentId
  Ord->>Inv: Consume
  Ord-->>GW: 201 paid
  GW-->>Buyer: 201 paid
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
  pending --> paid: payment ok + consume
  pending --> cancelled: shortage or payment fail
  paid --> [*]
  cancelled --> [*]
```

`shipped` は未実装。不正遷移のイベントストア拒否はスライス 3。

## 6. ER（論理）

```mermaid
erDiagram
  catalog_products ||--o{ inventory_stock_balances : "product_id 論理"
  inventory_sites ||--o{ inventory_stock_balances : site
  inventory_stock_balances ||--o{ inventory_stock_movements : history
  inventory_reservations }o--|| commerce_orders : order_id 論理
  commerce_orders ||--|{ commerce_order_lines : lines
  cart_items }o--|| catalog_products : product_id 論理
```

物理 FK は張っていない。プロセスごとに別 DB。列は各 `schema.sql` を正とする。
