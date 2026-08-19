# P15 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P15 habit-tracker |
| 対象スライス | 1 |
| 最終更新 | 2026-08-19 |

## ユースケース

```mermaid
flowchart LR
  user[個人]
  user --> today[今日チェック]
  user --> cal[カレンダー]
  user --> crud[習慣 CRUD]
  apiUser[APIデモユーザー]
  apiUser --> sync[habits/logs]
```

## 画面遷移（実装済み）

```mermaid
flowchart LR
  Today --> Detail
  Today --> New
  Detail --> Today
  New --> Today
```

通知設定・統計・アカウントは未実装。

## チェック（オフライン）

```mermaid
sequenceDiagram
  actor U as ユーザー
  participant UI as Expo
  participant DB as SQLite
  U->>UI: 今日をチェック
  UI->>UI: 今日 = TZ 暦日
  UI->>DB: upsert habit_logs
  Note over UI,DB: API は呼ばない
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

API は `users` を足し、habits.user_id で隔離する。
