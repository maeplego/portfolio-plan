# P09 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P09 attendance |
| 対象スライス | スライス 1 |
| 最終更新 | 2026-08-19 |
| 記法 | Mermaid |

## 1. ユースケース

```mermaid
flowchart LR
  Emp[従業員]
  Emp --> UC1[出勤する]
  Emp --> UC2[休憩する]
  Emp --> UC3[退勤する]
  Emp --> UC4[本日の分数を見る]
```

月次・承認は未実装。

## 2. 画面遷移

```mermaid
flowchart TB
  H[打刻ホーム /]
```

## 3. 打刻

```mermaid
sequenceDiagram
  actor U
  participant Web
  participant API
  U->>Web: 出勤
  Web->>API: POST /v1/punches type=clock_in
  Note over API: Instant.now(clock) と Tokyo 勤務日
  API-->>Web: 201
  Web->>API: GET /v1/me/daily-summary
  API-->>Web: 整数分
```

## 4. 日境界

```mermaid
sequenceDiagram
  participant C as Clock
  participant API
  C->>API: 2026-08-18T14:59:00Z
  API-->>API: workDate 2026-08-18
  C->>API: 2026-08-18T15:00:00Z
  API-->>API: workDate 2026-08-19
```

## 5. 状態（1 勤務日）

```mermaid
stateDiagram-v2
  [*] --> absent
  absent --> clocked_in: clock_in
  clocked_in --> on_break: break_start
  on_break --> clocked_in: break_end
  clocked_in --> clocked_out: clock_out
  clocked_out --> [*]
```

## 6. ER（論理）

```mermaid
erDiagram
  employees ||--o{ punches : records
  employees {
    text id
    text sub
    text display_name
    text role
  }
  punches {
    text id
    text punch_type
    timestamptz punched_at
    date work_date
  }
```
