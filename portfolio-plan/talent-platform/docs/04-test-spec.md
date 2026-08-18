# P10 talent-platform — テスト仕様

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小（webhook + provision） |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | `../pf-talent-api` の vitest |

## 方針

- MVP は DB を使わないため、`MemoryStore` の単体テスト（HTTP: `app.request`）を基本にする。
- Postgres / integration はこのスライスでは未実装。

## テストケース（例）

### TS-W01 webhook により application が interview へ更新される
- `POST /webhooks/calendar` に正しいヘッダとペイロードを送る
- `data.externalRef` に一致する application がある
- 期待: `200`、`status=interview`、`interviewBookingId` がセット

### TS-W02 provision endpoint が P05 internal API を呼ぶ
- `POST /v1/jobs/:id/provision-interview-event-type`
- `CALENDAR_INTERNAL_TOKEN` と `CALENDAR_API_URL` を設定
- 期待: `Authorization: Bearer ...` を付けて P05 の `POST /internal/v1/event-types` へ `externalRef = job.id` で送る

### TS-S01 不正な状態遷移は 409 を返す
- applied → interview は不正: `409 invalid_transition`

### TS-S02 正当な状態遷移は 200
- applied → document_passed: `200`

### TS-P01 候補者プロフィールの upsert / get
- `PUT /v1/profiles/:sub` → `200`
- `GET /v1/profiles/:sub` → プロフィール

### TS-P02 未知のプロフィールは 404
- `GET /v1/profiles/unknown` → `404`

### TS-J01 求人一覧（GET /v1/jobs）
- 求人作成後に一覧で取得

### TS-J02 拡張フィールド付き求人作成
- skills, salaryMin/Max, remote 等が保持される

