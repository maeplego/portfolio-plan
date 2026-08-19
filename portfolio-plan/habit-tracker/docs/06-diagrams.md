# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | habit-tracker（GitHub: [pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile)、[pf-habit-api](https://github.com/maeplego/pf-habit-api)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## ユースケース

```mermaid
flowchart LR
  user[個人]
  user --> today[今日チェック]
  user --> cal[カレンダー]
  user --> stats[統計 30日]
  user --> crud[習慣 CRUD]
  apiUser[APIデモユーザー]
  apiUser --> sync[habits/logs]
```

## 画面遷移（実装済み）

```mermaid
flowchart LR
  Today --> Detail
  Today --> New
  Today --> Stats
  Detail --> Today
  New --> Today
  Stats --> Today
```

通知設定とアカウント連携は未実装。統計は実装済み。

## チェック（オフライン・API なし）

```mermaid
sequenceDiagram
  actor U as ユーザー
  participant UI as Expo
  participant DB as SQLite
  U->>UI: 今日をチェック
  UI->>UI: 今日 = TZ 暦日
  UI->>DB: upsert habit_logs
  Note over UI,DB: pf-habit-api は呼ばない
```

## ER（モバイル SQLite / API Postgres 同型）

```mermaid
erDiagram
  habits ||--o{ habit_logs : logs
  habits {
    string id
    string name
    string schedule_kind
    int times_per_week
  }
  habit_logs {
    string habit_id
    date local_date
    bool completed
  }
```

API は `users` を足し、habits.user_id で隔離する。どちらも Kubernetes には載せない。
