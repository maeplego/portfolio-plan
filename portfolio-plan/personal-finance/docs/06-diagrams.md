# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## 1. ユースケース

```mermaid
flowchart LR
  User[個人]
  User --> UC1[月次を見る]
  User --> UC2[取引を追加する]
  User --> UC3[予算を置く]
  User --> UC4[グラフを見る]
  User --> UC5[CSV入出力]
  User --> UC6[PWAを入れる]
```

## 2. 画面遷移

```mermaid
flowchart TB
  H[今月 /]
  R[グラフ /reports]
  H --> R
  R --> H
```

CSV 操作はホーム上。起動の正は Compose。Kubernetes は ops overlay 経由。

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

## 4. CSV

```mermaid
sequenceDiagram
  actor U
  participant Web
  participant API
  U->>Web: 書き出し
  Web->>API: GET /v1/export.csv?month=
  API-->>Web: text/csv
  U->>Web: 取り込み
  Web->>API: POST /v1/import
  API-->>Web: 201 imported
```

## 5. 認可

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

## 6. ER（論理）

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
