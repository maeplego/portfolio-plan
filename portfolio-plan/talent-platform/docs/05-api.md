# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | talent-platform（GitHub: [pf-talent-api](https://github.com/maeplego/pf-talent-api)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 共通エラー

```json
{ "error": { "code": "invalid_request", "message": "..." } }
```

開発時の認可ヘッダ: `X-Dev-User-Sub`。Compose の店舗は Postgres。

## ヘルス

- `GET /health` → `{ "ok": true }`

## 求人検索

### GET `/v1/jobs`

| パラメータ | 型 | 意味 |
| --- | --- | --- |
| `q` | string | Postgres は `tsvector` + `pg_trgm`。日本語の部分文字列もヒット |
| `employmentType` | enum | `full_time` など |
| `remote` | bool | リモート可否 |
| `skills` | csv | スキルタグ（OR） |
| `salaryMin` / `salaryMax` | int | 求人の年収範囲との重なり |

フィルタなしは published のみ。draft は `GET /v1/employers/:sub/jobs`。

### GET `/v1/jobs/:id`

無い id は `404`。`/v1/jobs/facets` より後に登録する。

### GET `/v1/jobs/facets`

現在の検索条件で published の件数。`200 { total, employmentType, remote, skills }`。

### GET `/v1/jobs/:id/similar`

`k` 任意（既定 5、最大 20）。`source` が `recommend` なら [pf-recommend](https://github.com/maeplego/pf-recommend)、`fallback` ならスキル重なり。推薦の重なりが劣る・失敗するときは fallback。

### POST `/v1/jobs`

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

## 応募

### POST `/v1/jobs/:id/applications`

`{ "candidateSub", "resumeSnapshot" }`。初期の `calendarExternalRef` は job id。

### GET `/v1/applications/:id`

### PATCH `/v1/applications/:id/status`

不正遷移は `409 invalid_transition`。

- `applied` → `document_passed` \| `rejected`
- `document_passed` → `interview` \| `rejected`
- `interview` → `offered` \| `rejected`

### GET `/v1/jobs/:id/applications` / GET `/v1/candidates/:sub/applications`

当事者以外は 403。求人が無ければ 404。

### GET `/v1/applications/:id/interview-slots`

`rangeStart` と `rangeEnd` 必須。[pf-calendar](https://github.com/maeplego/pf-calendar) の公開枠。応募が `document_passed` または `interview` のときのみ。

### PUT `/v1/applications/:id/calendar-link`

`{ "externalRef": "..." }`。

## 保存検索・プロフィール・通報

- `POST /v1/saved-searches`、`GET /v1/candidates/:sub/saved-searches`、`POST /v1/saved-searches/:id/run`
- `PUT` / `GET /v1/profiles/:sub`
- `POST /v1/reports`、`GET /v1/reports`（open のみ）
- `POST /v1/dev/seed`（架空デモ求人）

## webhook

### POST `/webhooks/calendar`

ヘッダ: `X-Calendar-Event-Type: calendar.booking.confirmed`。対象あり `matched: true`、なし `matched: false`。
