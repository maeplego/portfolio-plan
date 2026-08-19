# P10 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | webhook 連携契約 + 検索画面 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 画面遷移（実装済み: 検索 / 詳細）

```mermaid
flowchart LR
  login[DevUserGate] --> search[JobSearch]
  search --> detail[JobDetail]
  detail --> similar[SimilarJobs]
  detail --> apply[Apply]
  apply --> myApps[MyApplications]
  emp[employer] --> jobs[MyJobs]
  jobs --> apps[ApplicantList]
  apps --> slots[InterviewSlots_P05]
```

ゲスト画面は無い。`?user=` 必須。同じ応募でも候補者はタイトルと自分のステータス、企業は履歴書全文と遷移操作。他社は 403。

## シーケンス（予約確定 → interview 更新）

```mermaid
sequenceDiagram
  participant Worker as pf-calendar worker
  participant P05API as pf-calendar apps/api
  participant Talent as pf-talent-api
  participant Store as application store

  Worker->>P05API: outbox delivered (POST /webhooks/calendar)
  P05API->>Talent: X-Calendar-Event-Type + calendar.booking.confirmed
  Talent->>Store: find application by calendarExternalRef (data.externalRef)
  Store-->>Talent: application or null
  alt matched
    Talent->>Store: status=interview, interviewBookingId=bookingId
  else not matched
    Talent-->>Worker: ok=true, matched=false
  end
  Talent-->>Worker: ok=true
```

## ER（検索まわり）

```mermaid
erDiagram
  jobs {
    text id PK
    text title
    text description
    text location
    text[] skills
    tsvector search_tsv
  }
```

`search_tsv` は generated。GIN + `pg_trgm`。OpenSearch テーブルは無い。

