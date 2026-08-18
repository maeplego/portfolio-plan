# P10 talent-platform — 外部仕様

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小（jobs/applications + webhook受信） |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | `../DESIGN.md` と `../pf-talent-api` |

## 時刻

- 本 MVP は時刻を保持・表示しない。ただし webhook エンベロープの `occurredAt` を受け取っても内部更新に使わない。

## webhook 契約（P05 → P10）

- HTTP: `POST /webhooks/calendar`
- 必須ヘッダ:
  - `X-Calendar-Event-Type: calendar.booking.confirmed`
- 必須本文:
  - `calendar.booking.confirmed` エンベロープ（`id`, `type`, `occurredAt`, `data` を含む）
- `data.externalRef`：
  - **MVP では job id**。P05 の `event_type.externalRef` を P10 の application に紐付けるためのキー。

### 成功時

- 対象 application がある場合: `200 { ok: true, matched: true, applicationId, status }`
- 対象 application がない場合: `200 { ok: true, matched: false }`

### エラー

- ヘッダ不一致 / ペイロード不正: `400 { error: { code: "invalid_request", message } }`

## API 契約（MVP）

### `POST /v1/jobs`

入力:

```json
{ "employerSub": "employer-1", "title": "Backend Engineer", "status": "published" }
```

出力: job そのもの（`id` 含む）。詳細は `05-api.md`。

### `POST /v1/jobs/:id/applications`

入力:

```json
{ "candidateSub": "candidate-1", "resumeSnapshot": "..." }
```

出力: application（`id`, `jobId`, `status`, `calendarExternalRef` を含む）。
MVP では `calendarExternalRef` は **`jobId` と同じ値**で初期化する。

### `PUT /v1/applications/:id/calendar-link`

入力:

```json
{ "externalRef": "job-id-or-externalRef" }
```

出力: 更新後 application。

### `PATCH /v1/applications/:id/status`

入力:

```json
{ "status": "applied" | "document_passed" | "interview" | "rejected" }
```

出力: 更新後 application。

### `GET /v1/applications/:id`

出力: application。存在しない場合 `404 not_found`。

