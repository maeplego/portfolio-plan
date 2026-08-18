# P10 API 仕様書（MVP）

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | 最小フロー + 検索フィルタ + 保存検索 |
| 最終更新 | 2026-08-18 |

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
| `q` | string | `kubernetes` | title / description のキーワード部分一致 |
| `employmentType` | enum | `full_time` | 雇用形態 |
| `remote` | bool | `true` | リモート可否 |
| `skills` | csv | `Go,PostgreSQL` | スキルタグ（OR 一致） |
| `salaryMin` | int | `5000000` | 求人の salaryMax がこの値以上 |
| `salaryMax` | int | `8000000` | 求人の salaryMin がこの値以下 |

フィルタなしの場合は全件返す。検索は published のみ対象。

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

