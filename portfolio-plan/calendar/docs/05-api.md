# P05 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P05 calendar |
| 対象スライス | 1–11 実装済みの HTTP。OpenAPI は `packages/openapi/openapi.yaml` と `GET /openapi.yaml` |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8095`（Compose）。時刻は Instant の ISO-8601 |

機械可読 OpenAPI は `packages/openapi/openapi.yaml`。API は `GET /openapi.yaml` で同内容を返す。本ファイルは人間向け要約。

## ドメインイベント（P10）

予約 **新規確定**（201、冪等再送 200 ではない）時に `outbox_events` へ enqueue。worker が `CALENDAR_WEBHOOK_URL` へ POST する。

```json
{
  "id": "...",
  "type": "calendar.booking.confirmed",
  "occurredAt": "2026-03-02T00:00:00Z",
  "data": {
    "bookingId": "...",
    "eventTypeId": "...",
    "externalRef": "job-1",
    "hostSub": "employer-1",
    "slug": "interview-30",
    "start": "...",
    "end": "...",
    "guestName": "...",
    "guestEmail": "...",
    "guestTimeZone": "..."
  }
}
```

ヘッダ: `Content-Type: application/json`、`X-Calendar-Event-Type: calendar.booking.confirmed`。`CALENDAR_WEBHOOK_URL` 未設定時 worker は配信をスキップ。

## Dev webhook（P10 結合の土台）

P10 結合がまだ無い場合の **疎通スタブ**。worker が POST する outbox 配信を受けて 200 を返す。

### POST `/webhooks/calendar`

ヘッダ: `X-Calendar-Event-Type: calendar.booking.confirmed`

本文: `calendar.booking.confirmed` エンベロープ（`id`, `type`, `occurredAt`, `data` を含む）。

| 条件 | 状態 |
| --- | --- |
| 正しいペイロード + ヘッダ | 200 `{ "ok": true }` |
| ヘッダ欠落 / 形式不正 | 400 `invalid_request` |

## 共通

Instant は `Temporal.Instant.toString()` 相当（例 `2026-03-02T00:00:00Z`）。エラー本文:

```json
{ "error": { "code": "slot_unavailable", "message": "slot unavailable" } }
```

ホスト API は `X-Dev-Host-Sub: <sub>`。`Content-Type: application/json`。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | store ping |

## 公開

### GET `/public/:slug/slots`

クエリ: `rangeStart`（必須）、`rangeEnd`（必須）、`now`（任意・テスト用）。

成功 200:

```json
{
  "slug": "casual-30",
  "name": "Casual 30",
  "durationMinutes": 30,
  "hostTimeZone": "Asia/Tokyo",
  "starts": ["2026-03-02T00:00:00Z"]
}
```

| 条件 | 状態 |
| --- | --- |
| range 欠落・不正・14×24h 超 | 400 `invalid_request` |
| slug なし | 404 `not_found` |

PII フィールドを足さない。

### POST `/public/:slug/book`

```json
{
  "slotStart": "2026-03-02T00:00:00Z",
  "name": "Guest A",
  "email": "a@example.test",
  "guestTimeZone": "America/Los_Angeles",
  "idempotencyKey": "idem-aaaaaaaa"
}
```

| 条件 | 状態 | 本文の要点 |
| --- | --- | --- |
| 新規確定 | 201 | `id`, `start`, `end`, `guestTimeZone`, `cancelToken` |
| 同じ冪等キー・同じ内容 | 200 | 上に同じだが `cancelToken` なし |
| オファー外・重なり | 409 | `slot_unavailable`。PII なし |
| 冪等キーの中身不一致 | 409 | `conflict` |
| バリデーション / 不正 TZ | 400 | |
| slug なし | 404 | |

`cancelToken` はログに出さない。再 GET できない。

### POST `/public/bookings/cancel`

```json
{ "cancelToken": "<平文トークン>" }
```

| 条件 | 状態 | 本文の要点 |
| --- | --- | --- |
| 有効トークン | 200 | `{ "status": "cancelled" }`。枠は exclusion 対象外になり再予約可 |
| トークン欠落 | 400 | `invalid_request` |
| 不明・取消済み | 404 | PII なし |

### GET `/public/bookings/ics`

クエリ: `token`（必須、`cancelToken` 平文）。

| 条件 | 状態 | 本文 |
| --- | --- | --- |
| 有効 | 200 | `text/calendar`。`Content-Disposition: attachment` |
| 欠落 | 400 | |
| 不明 | 404 | |

## ホスト `/v1`

すべて開発ヘッダ必須。不足は 401。他人の id は 404。

### POST `/v1/event-types`

| フィールド | 制約 |
| --- | --- |
| slug | 1–64、`^[a-z0-9]+(?:-[a-z0-9]+)*$`、グローバル一意 |
| name | 1–120 |
| durationMinutes | 正の整数 |
| bufferMinutes | 0 以上、省略時 0 |
| minNoticeMinutes | 0 以上、省略時 0 |
| hostTimeZone | IANA |
| rules | `{ dayOfWeek: 1–7, startLocal, endLocal }[]` |

201: id, slug, name, duration, buffer, minNotice, hostTimeZone, rules, overrides。slug 衝突 409。

### GET `/v1/event-types`

200 `{ "eventTypes": [ ... ] }`。自ホストのみ。

### GET `/v1/event-types/:id`

200 1 件。または 404。

### PUT `/v1/event-types/:id/rules`

`{ "rules": [ ... ] }` 全置換。200 は GET と同じ形。

### PUT `/v1/event-types/:id/overrides`

`{ "overrides": [ { "date": "YYYY-MM-DD", "blocked": true } ] }` 全置換。

### GET `/v1/event-types/:id/slots`

公開 slots と同じクエリ。本文は `{ "starts": [ ... ] }` のみ。

### GET `/v1/event-types/:id/bookings`

確定予約。ゲスト氏名・メールあり。公開には出さない。

```json
{
  "bookings": [
    {
      "id": "...",
      "start": "2026-03-02T00:00:00Z",
      "end": "2026-03-02T00:30:00Z",
      "guestName": "Guest A",
      "guestEmail": "a@example.test",
      "guestTimeZone": "America/Los_Angeles",
      "status": "confirmed"
    }
  ]
}
```

`cancelToken` / ハッシュは返さない。

## 内部 `/internal/v1`（P10）

`CALENDAR_INTERNAL_TOKEN` が空なら **503** `unavailable`。設定時は `Authorization: Bearer ${CALENDAR_INTERNAL_TOKEN}` 必須。不正は 401。

### POST `/internal/v1/event-types`

ホスト API と同じイベントタイプフィールドに加え:

| フィールド | 制約 |
| --- | --- |
| hostSub | 必須。P01 の `sub`（企業ユーザー） |
| externalRef | 任意。同一 host 内で冪等。既存があれば 200 で返す（slug 衝突は起こさない） |

201: 新規。200: `externalRef` 一致で既存返却。

### GET `/internal/v1/hosts/:sub/event-types`

200 `{ "eventTypes": [ ... ] }`。ホスト API と同形（`externalRef` 含む）。

### GET `/internal/v1/bookings/:id`

200:

```json
{
  "booking": {
    "id": "...",
    "eventTypeId": "...",
    "start": "...",
    "end": "...",
    "guestName": "...",
    "guestEmail": "...",
    "guestTimeZone": "...",
    "status": "confirmed"
  },
  "eventType": {
    "slug": "...",
    "name": "...",
    "hostTimeZone": "..."
  }
}
```

404: id なし。`cancelToken` は返さない。

## 未実装（契約予約）

| 予定 | 備考 |
| --- | --- |
| P10 側 webhook 受信と応募ステータス更新 | pf-talent-api |
