# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | talent-platform（GitHub: [pf-talent-api](https://github.com/maeplego/pf-talent-api)、[pf-talent-web](https://github.com/maeplego/pf-talent-web)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## 画面遷移

```mermaid
flowchart LR
  login[DevUserGate] --> search[JobSearch]
  search --> detail[JobDetail]
  detail --> similar[SimilarJobs]
  detail --> apply[Apply]
  apply --> myApps[MyApplications]
  emp[employer] --> jobs[MyJobs]
  jobs --> apps[ApplicantList]
  apps --> slots[InterviewSlots]
```

ゲスト画面は無い。`?user=` 必須。同じ応募でも候補者はタイトルと自分のステータス、企業は履歴書全文と遷移操作。他社は 403。面接枠は [pf-calendar](https://github.com/maeplego/pf-calendar) の公開ページへ誘導する。

## 予約確定 → 応募ステータス interview

```mermaid
sequenceDiagram
  participant Worker as pf-calendar worker
  participant CalAPI as pf-calendar apps/api
  participant Talent as pf-talent-api
  participant Store as Postgres

  Worker->>CalAPI: outbox delivered
  CalAPI->>Talent: POST /webhooks/calendar
  Talent->>Store: find by calendarExternalRef
  Store-->>Talent: application or null
  alt matched
    Talent->>Store: status=interview, interviewBookingId
  else not matched
    Talent-->>Worker: ok=true, matched=false
  end
  Talent-->>Worker: ok=true
```

## 類似求人（閉じる）

```mermaid
flowchart TB
  Req[GET /v1/jobs/id/similar]
  Rec[pf-recommend similar-items]
  Skill[スキル重なり fallback]
  Req --> Rec
  Rec -->|成功かつ重なりが劣らない| OutR[source recommend]
  Rec -->|未接続・失敗・重なりが劣る| Skill
  Skill --> OutF[source fallback]
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
  applications {
    text id PK
    text job_id FK
    text status
    text calendar_external_ref
  }
  jobs ||--o{ applications : receives
```

`search_tsv` は generated。GIN + `pg_trgm`。OpenSearch テーブルは無い。Compose の正は Postgres。
