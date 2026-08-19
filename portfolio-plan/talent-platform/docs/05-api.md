# P10 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | 最小フロー + 検索フィルタ + 保存検索 + 求人GET / 応募一覧 ACL |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 共通エラー形

```json
{ "error": { "code": "invalid_request", "message": "..." } }
```

## ヘルス

- `GET /health` → `{ "ok": true }`

## jobs / applications

### GET `/v1/jobs`

求人一覧。クエリパラメータでフィルタ:

| パラメータ | 型 | 例 | 意味 |
| --- | --- | --- | --- |
| `q` | string | `kubernetes` / `エンジ` | Postgres は `tsvector` + `pg_trgm`（title / description / location / skills）。日本語の部分文字列もヒット。メモリ実装は同じフィールドの部分一致 |
| `employmentType` | enum | `full_time` | 雇用形態 |
| `remote` | bool | `true` | リモート可否 |
| `skills` | csv | `Go,PostgreSQL` | スキルタグ（OR 一致） |
| `salaryMin` | int | `5000000` | 求人の salaryMax がこの値以上 |
| `salaryMax` | int | `8000000` | 求人の salaryMin がこの値以下 |

フィルタなしの場合は published のみ返す。draft は `GET /v1/employers/:sub/jobs` 側。

開発時の認可ヘッダ: `X-Dev-User-Sub`。`TALENT_DEV_AUTH` 未設定でもこのヘッダを信じる（OIDC 必須は後続）。

### GET `/v1/jobs/:id`

求人詳細。無い id は `404 not_found`。`/v1/jobs/facets` より後に登録する。

### GET `/v1/employers/:sub/jobs`

その企業の求人（draft 含む）。`X-Dev-User-Sub` が `:sub` と一致しないと `403 forbidden`。

### GET `/v1/jobs/:id/applications`

その求人の応募一覧。求人が無ければ `404`。`X-Dev-User-Sub` が当該 `employerSub` と一致しないと `403`。

### GET `/v1/candidates/:sub/applications`

候補者の応募一覧。ヘッダが `:sub` と一致しないと `403`。

### POST `/v1/dev/seed`

架空企業のデモ求人 8〜12 件を投入する。実在企業名は使わない。起動時にも空ストアへ投入する。

## 保存検索

### POST `/v1/saved-searches`

入力:

```json
{
  "candidateSub": "candidate-1",
  "name": "Remote Go",
  "query": "go",
  "remote": true,
  "skills": ["Go"],
  "salaryMin": 5000000
}
```

### GET `/v1/candidates/:sub/saved-searches`

候補者の保存検索一覧を返す。

### POST `/v1/saved-searches/:id/run`

保存検索を現在時点の求人に対して再実行する。

出力:

```json
{
  "savedSearch": { "id": "01...", "lastRunAt": "2026-08-18T08:00:00.000Z" },
  "matchedJobs": [{ "id": "01...", "title": "Go Remote" }],
  "matchedCount": 1
}
```

## P05 slot 連携

### GET `/v1/applications/:id/interview-slots`

クエリ:

- `rangeStart` 必須
- `rangeEnd` 必須

P05 calendar の候補スロットを返す。application が `document_passed` または `interview` のときのみ利用可。

成功例:

```json
{
  "slug": "interview-30m-demo",
  "name": "Interview 30m",
  "durationMinutes": 30,
  "hostTimeZone": "Asia/Tokyo",
  "starts": ["2026-08-19T01:00:00Z"]
}
```

## 類似求人

### GET `/v1/jobs/:id/similar`

クエリ:

- `k` 任意（既定 5、最大 20）

成功例:

```json
{
  "source": "fallback",
  "jobs": [
    { "id": "01...", "title": "Go Dev", "skills": ["Go"] }
  ]
}
```

`source` が `recommend` の場合は P07 の結果、`fallback` の場合は P10 内の skills overlap。

## ファセット件数

### GET `/v1/jobs/facets`

現在の検索条件に基づき published jobs を集計して facet counts を返す。

## 管理通報

### POST `/v1/reports`

入力:

```json
{ "reporterSub": "candidate-1", "jobId": "job-id", "reason": "spam" }
```

### GET `/v1/reports`

通報一覧を返す（`open` のみを扱う MVP）。 

### POST `/v1/jobs`

入力:

```json
{
  "employerSub": "employer-1",
  "title": "Backend Engineer",
  "status": "published",
  "employmentType": "full_time",
  "location": "Tokyo",
  "remote": true,
  "salaryMin": 5000000,
  "salaryMax": 8000000,
  "skills": ["Go", "PostgreSQL"],
  "description": "..."
}
```

`employmentType`: `full_time` | `contract` | `part_time` | `internship`（デフォルト `full_time`）。
`salaryMin` / `salaryMax`: 整数（最小通貨単位）。nullable。

### POST `/v1/jobs/:id/applications`

入力:

```json
{ "candidateSub": "candidate-1", "resumeSnapshot": "..." }
```

### GET `/v1/applications/:id`

### PATCH `/v1/applications/:id/status`

入力:

```json
{ "status": "document_passed" }
```

状態遷移ルール（不正遷移は `409 invalid_transition`）:

- `applied` → `document_passed` | `rejected`
- `document_passed` → `interview` | `rejected`
- `interview` → `offered` | `rejected`
- `offered` / `rejected` → （終端）

## 候補者プロフィール

### PUT `/v1/profiles/:sub`

入力:

```json
{
  "sub": "candidate-1",
  "displayName": "Alice",
  "skills": ["TypeScript"],
  "desiredEmploymentTypes": ["full_time"],
  "desiredMinSalary": 4000000,
  "desiredRemote": true,
  "bio": "..."
}
```

### GET `/v1/profiles/:sub`

存在しない場合 `404 not_found`。

### PUT `/v1/applications/:id/calendar-link`

入力:

```json
{ "externalRef": "job-id-or-externalRef" }
```

## webhook（P05 → P10）

### POST `/webhooks/calendar`

ヘッダ: `X-Calendar-Event-Type: calendar.booking.confirmed`

本文: P05 `calendar.booking.confirmed` エンベロープ（`id`, `type`, `occurredAt`, `data`）

成功:

- 対象あり: `200 { ok: true, matched: true, applicationId, status }`
- 対象なし: `200 { ok: true, matched: false }`

