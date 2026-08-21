# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | habit-tracker（GitHub: [pf-habit-api](https://github.com/maeplego/pf-habit-api)） |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

ベース URL: `http://localhost:8015`（Compose）。認可: `X-Dev-User-Sub` または任意の OIDC Bearer（`/v1/*`）。OpenAPI ファイルは未着手。[pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile) は任意でこの API と差分同期する。Kubernetes 向けマニフェストは置かない。

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

### `PATCH /v1/habits/:id`

部分更新。少なくとも 1 フィールド必須。

```json
{ "name": "夜のストレッチ", "color": "#16A34A", "scheduleKind": "weekly", "timesPerWeek": 3, "archived": true }
```

- `name` / `color` / `scheduleKind` / `timesPerWeek` — 任意。スケジュール系を触ると既存値とマージして検証（`weekly` は `timesPerWeek` 1–7）
- `archived: true` — アーカイブ。以降 `GET /v1/habits` 一覧から外れる（`GET /v1/habits/:id` は取得可）
- 200 Habit / 他人なら 404

### `GET /v1/habits/:id/logs?from=YYYY-MM-DD&to=YYYY-MM-DD`

200 `{ "logs": HabitLog[] }`。

### `PUT /v1/habits/:id/logs/:date`

`:date` は YYYY-MM-DD。本文 `{ "completed": true, "note": "" }`。200 HabitLog。

## 形

Habit: `id`, `userId`, `name`, `color`, `scheduleKind`, `timesPerWeek`, `archived`, `createdAt`, `updatedAt`

HabitLog: `habitId`, `localDate`, `completed`, `note`, `updatedAt`
