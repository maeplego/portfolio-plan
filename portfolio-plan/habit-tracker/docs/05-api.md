# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | habit-tracker（GitHub: [pf-habit-api](https://github.com/maeplego/pf-habit-api)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

ベース URL: `http://localhost:8015`（Compose）。認可: `X-Dev-User-Sub`（`/v1/*`）。OpenAPI ファイルは未着手。[pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile) はいまこの API を呼ばない。Kubernetes 向けマニフェストは置かない。

## ヘルス

| メソッド | パス | 認証 | 成功 |
| --- | --- | --- | --- |
| GET | `/health` | なし | `{ "ok": true }` |
| GET | `/ready` | なし | `{ "ok": true }` / ストア不可なら 503 |

## 習慣

### `GET /v1/habits`

200 `{ "habits": Habit[] }` 自分の未アーカイブ。

### `POST /v1/habits`

```json
{ "name": "朝のストレッチ", "color": "#2563EB", "scheduleKind": "daily", "timesPerWeek": null }
```

201 Habit。`scheduleKind=weekly` なら `timesPerWeek` は 1–7。

### `GET /v1/habits/:id`

200 Habit / 他人なら 404。

### `GET /v1/habits/:id/logs?from=YYYY-MM-DD&to=YYYY-MM-DD`

200 `{ "logs": HabitLog[] }`。

### `PUT /v1/habits/:id/logs/:date`

`:date` は YYYY-MM-DD。本文 `{ "completed": true, "note": "" }`。200 HabitLog。

## 形

Habit: `id`, `userId`, `name`, `color`, `scheduleKind`, `timesPerWeek`, `archived`, `createdAt`, `updatedAt`

HabitLog: `habitId`, `localDate`, `completed`, `note`, `updatedAt`
