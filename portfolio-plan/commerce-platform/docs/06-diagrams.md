# P06 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | シーケンス・状態・ER はスライス 1。画面は実装済み。抽出後は計画 |
| 最終更新 | 2026-08-19 |
| 記法 | Mermaid。ユースケースは UML 楕円の代替としてフロー |

## 1. ユースケース

```mermaid
flowchart LR
  subgraph actors [アクター]
    Buyer[購入者]
    Ops[ops]
  end
  subgraph uc [P06 スライス1]
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
  participant API as order module
  participant Inv as inventory
  participant Pay as payment mock
  Buyer->>API: POST /v1/checkout + Idempotency-Key
  API->>Inv: Reserve
  Inv-->>API: held
  API->>Pay: Charge(no PAN)
  Pay-->>API: paymentId
  API->>Inv: Consume
  API-->>Buyer: 201 paid
```

## 4. 在庫不足（同時 2 人）

```mermaid
sequenceDiagram
  actor A
  actor B
  participant API
  participant Inv
  A->>API: checkout qty 1
  B->>API: checkout qty 1
  API->>Inv: TryReserve A
  Inv-->>API: ok reserved=1
  API->>Inv: TryReserve B
  Inv-->>API: shortage
  API-->>A: 201 paid
  API-->>B: 409 inventory_shortage
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

物理 FK は張っていない。列は `schema.sql` を正とする。
