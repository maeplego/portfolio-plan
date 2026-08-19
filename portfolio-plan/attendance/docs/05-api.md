# P09 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P09 attendance |
| 対象スライス | スライス 1 の HTTP。OpenAPI は未作成 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8019`（Compose） |

エラー本文:

```json
{ "error": { "code": "conflict", "message": "already clocked in" } }
```

開発認証: `X-Dev-User-Sub`。`Content-Type: application/json`。クライアントの `punchedAt` は無視する。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | memory は常に 200。jpa は Postgres ping |

## 自分

### GET `/v1/me`

200 `{ "id", "sub", "displayName", "role", "zone" }`。`zone` は `Asia/Tokyo`。

### GET `/v1/me/daily-summary?date=YYYY-MM-DD`

`date` 省略はサーバーの Tokyo 今日。200:

```json
{
  "workDate": "2026-08-19",
  "workMinutes": 480,
  "breakMinutes": 60,
  "status": "clocked_out",
  "punches": [
    {
      "id": "...",
      "employeeId": "...",
      "type": "clock_in",
      "punchedAt": "2026-08-19T00:00:00Z",
      "workDate": "2026-08-19",
      "source": "web"
    }
  ]
}
```

`workMinutes` / `breakMinutes` は整数。`status` は `absent` \| `clocked_in` \| `on_break` \| `clocked_out`。

## 打刻

### POST `/v1/punches`

```json
{ "type": "clock_in" }
```

`type`: `clock_in` \| `clock_out` \| `break_start` \| `break_end`。201 は punch 1 件。順序違反は 409。未知 type は 400。
