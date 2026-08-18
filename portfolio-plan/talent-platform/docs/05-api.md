# P10 API 仕様書（MVP）

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | 最小フロー（jobs/applications + webhook） |
| 最終更新 | 2026-08-18 |

## 共通エラー形

```json
{ "error": { "code": "invalid_request", "message": "..." } }
```

## ヘルス

- `GET /health` → `{ "ok": true }`

## jobs / applications

### POST `/v1/jobs`

入力:

```json
{ "employerSub": "employer-1", "title": "Backend Engineer", "status": "published" }
```

### POST `/v1/jobs/:id/applications`

入力:

```json
{ "candidateSub": "candidate-1", "resumeSnapshot": "..." }
```

### GET `/v1/applications/:id`

### PATCH `/v1/applications/:id/status`

入力:

```json
{ "status": "applied" }
```

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

