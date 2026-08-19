# P14 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P14 personal-finance |
| 対象スライス | スライス 1 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 記法 | Mermaid |

## 1. ユースケース

```mermaid
flowchart LR
  User[個人]
  User --> UC1[月次を見る]
  User --> UC2[取引を追加する]
  User --> UC3[予算を置く]
  User --> UC4[グラフを見る]
  User --> UC5[PWAを入れる]
```

## 2. 画面遷移

```mermaid
flowchart TB
  H[今月 /]
  R[グラフ /reports]
  H --> R
  R --> H
```

## 3. 取引追加

```mermaid
sequenceDiagram
  actor U
  participant Web
  participant API
  participant DB
  U->>Web: 整数円を入力
  Web->>API: POST /v1/transactions + X-Dev-User-Sub
  API->>API: parsePositiveYen
  API->>DB: INSERT user_id 付き
  API-->>Web: 201
  Web->>API: GET /v1/reports/monthly
  API-->>Web: 整数の合計
```

## 4. 認可

```mermaid
sequenceDiagram
  actor Alice
  actor Bob
  participant API
  Alice->>API: POST transaction
  Bob->>API: GET that id
  API-->>Bob: 404
  Bob->>API: GET month list
  API-->>Bob: transactions []
```

## 5. ER（論理）

```mermaid
erDiagram
  users ||--o{ categories : owns
  users ||--o{ transactions : owns
  users ||--o{ budgets : owns
  categories ||--o{ transactions : classifies
  users {
    text id
    text sub
  }
  transactions {
    int amount_yen
    date occurred_on
    text kind
  }
  budgets {
    char month
    int limit_yen
  }
```
