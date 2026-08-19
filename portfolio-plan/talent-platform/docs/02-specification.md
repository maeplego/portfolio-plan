# P10 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小 + 検索フィルタ + 保存検索 + 一覧 ACL |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

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

### `GET /v1/jobs` の `q`

Postgres では `jobs.search_tsv`（`simple`）の全文検索と `pg_trgm` による部分一致・類似を OR する。フィルタ無しのときは published を `created_at` 順。`q` があるときは関連度（`ts_rank_cd` と title の trigram）を先にし、同点は `created_at`。OpenSearch は使わない。

### `POST /v1/saved-searches`

候補者の保存検索を作成する。`name` と検索条件を保存し、後続の新着判定に使う。

### `GET /v1/candidates/:sub/saved-searches`

候補者に紐づく保存検索一覧を返す。

### `POST /v1/saved-searches/:id/run`

保存検索を現在時点で再実行し、`matchedJobs` と `matchedCount` を返す。MVP では非同期ジョブ化せず同期で返す。

### `GET /v1/applications/:id/interview-slots`

P05 calendar の `GET /public/:slug/slots` を利用して候補スロットを返す。P10 側ではまず internal API でホストの event type 一覧を取得し、`externalRef = job.id` の event type を探して slug を特定する。

- `rangeStart`, `rangeEnd` は必須
- application が `document_passed` または `interview` でない場合は `409 invalid_state`
- 対応する event type が無ければ `404`

### `GET /v1/jobs/:id/similar`

類似求人一覧を返す。

- `RECOMMEND_API_URL` が設定され、P07 `/v1/similar-items?namespace=jobs&item_id=&k=` が成功する場合はその結果を使う
- P07 が未接続または失敗時は P10 内の `skills` overlap でフォールバック
- 返り値には `source: "recommend" | "fallback"` を含む

### ファセット件数

### `GET /v1/jobs/facets`

現在の検索条件（`q`, `employmentType`, `remote`, `skills`, `salaryMin`, `salaryMax`）を使い、published jobs への facet counts を返す。

- 成功: `200 { total, employmentType, remote, skills }`

### 管理通報

### `POST /v1/reports`

通報を作成する。

入力:

```json
{ "reporterSub": "candidate-1", "jobId": "job-id", "reason": "spam" }
```

成功: `201 { id, reporterSub, jobId, reason, status: "open", createdAt }`

### `GET /v1/reports`

通報一覧を返す（MVP では `open` のみ表示）。

### `GET /v1/jobs/:id`

存在する求人を返す。無い id は `404`。

### `GET /v1/employers/:sub/jobs`

企業の求人一覧（draft 含む）。`X-Dev-User-Sub` ≠ `:sub` なら `403`。

### `GET /v1/jobs/:id/applications`

求人の応募一覧。他社ヘッダは `403`。求人が無ければ `404`。

### `GET /v1/candidates/:sub/applications`

候補者の応募一覧。ヘッダ ≠ `:sub` なら `403`。

### `POST /v1/dev/seed`

架空デモ求人を投入。起動時にも空ストアへ投入する。

