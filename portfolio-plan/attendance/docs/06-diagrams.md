# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | attendance（GitHub: [pf-attendance](https://github.com/maeplego/pf-attendance)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## 1. ユースケース

```mermaid
flowchart LR
  Emp[従業員]
  Emp --> UC1[出勤する]
  Emp --> UC2[休憩する]
  Emp --> UC3[退勤する]
  Emp --> UC4[本日の分数を見る]
  Emp --> UC5[月次カレンダーを見る]
```

申請・承認・締めは未実装。

## 2. 画面遷移

```mermaid
flowchart TB
  H[打刻ホーム /]
  C[月次カレンダー /calendar]
  H --> C
  C --> H
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

## 4. 月次カレンダー

```mermaid
sequenceDiagram
  actor U
  participant Web
  participant API
  U->>Web: /calendar で月を選ぶ
  Web->>API: GET /v1/me/month-summary?month=2026-08
  API-->>Web: 31 日分の分数と状態
```

## 5. 日境界

```mermaid
sequenceDiagram
  participant C as Clock
  participant API
  C->>API: 2026-08-18T14:59:00Z
  API-->>API: workDate 2026-08-18
  C->>API: 2026-08-18T15:00:00Z
  API-->>API: workDate 2026-08-19
```

## 6. 状態（1 勤務日）

```mermaid
stateDiagram-v2
  [*] --> absent
  absent --> clocked_in: clock_in
  clocked_in --> on_break: break_start
  on_break --> clocked_in: break_end
  clocked_in --> clocked_out: clock_out
  clocked_out --> [*]
```

## 7. ER（論理）

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
