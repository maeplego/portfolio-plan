# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-20 |
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
  User --> UC7[オフライン入力を同期する]
  User --> UC8[ウォレットと繰り返し]
  User --> UC9[アカウントを消す]
```

## 2. 画面遷移

```mermaid
flowchart TB
  H[今月 /]
  R[グラフ /reports]
  L[ログイン /login]
  H --> R
  R --> H
  H --> L
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
  Web->>API: POST /v1/transactions + X-Dev-User-Sub（BFF 経由）
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

## 5. LWW 同期

成功:

```mermaid
sequenceDiagram
  actor U
  participant Web
  participant API
  U->>Web: オフラインで入力
  Web->>Web: IndexedDB キュー
  U->>Web: オンライン復帰
  Web->>API: POST /v1/sync changes
  API->>API: decideLww
  API-->>Web: applied
```

競合（同時刻またはサーバーが新しい）:

```mermaid
sequenceDiagram
  participant Web
  participant API
  Web->>API: POST /v1/sync 古い updatedAt
  API->>API: keep_server
  API-->>Web: rejected server_newer
```

## 6. 認可

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

## 7. ER（論理）

```mermaid
erDiagram
  users ||--o{ categories : owns
  users ||--o{ wallets : owns
  users ||--o{ transactions : owns
  users ||--o{ budgets : owns
  users ||--o{ recurring_rules : owns
  wallets ||--o{ transactions : holds
  categories ||--o{ transactions : classifies
  recurring_rules ||--o{ recurring_generations : logs
  users {
    text id
    text sub
  }
  wallets {
    text name
  }
  transactions {
    int amount_yen
    date occurred_on
    text kind
    timestamptz updated_at
    timestamptz deleted_at
  }
  recurring_rules {
    int day_of_month
  }
  budgets {
    char month
    int limit_yen
  }
```
