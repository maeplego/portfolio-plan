# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | attendance（GitHub: [pf-attendance](https://github.com/maeplego/pf-attendance)） |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | `http://localhost:8019`（Compose） |

OpenAPI ファイルは未作成。エラー本文:

```json
{ "error": { "code": "conflict", "message": "already clocked in" } }
```

開発認証: `X-Dev-User-Sub`（任意 `X-Dev-User-Org`）。`Content-Type: application/json`。通常打刻のクライアント `punchedAt` は無視する（サーバー時刻が正）。事後打刻は本文の `workDate` / `at` を使う。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | memory は常に 200。jpa は Postgres ping |

## 自分

### GET `/v1/me`

200 `{ "id", "sub", "displayName", "role", "zone", "engagement", "worksiteCode", "worksiteName" }`。`zone` は `Asia/Tokyo`。`engagement` は `employed` \| `client_site`。

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

`workMinutes` / `breakMinutes` は整数。`status` は `absent` \| `clocked_in` \| `on_break` \| `clocked_out`。`source` は `web`（通常）または `manual`（事後）。

### GET `/v1/me/month-summary?month=YYYY-MM`

月次カレンダー UI が使う。200 `{ "month", "zone": "Asia/Tokyo", "days": [ { workDate, workMinutes, breakMinutes, status, punchCount } ] }`。`days` はその月の暦日すべて（8 月は 31）。他人の打刻は 0。不正な month は 400。

## 打刻

### POST `/v1/punches`

```json
{ "type": "clock_in", "workDate": "2026-08-18", "at": "09:00" }
```

`type`: `clock_in` \| `clock_out` \| `break_start` \| `break_end`。201 は punch 1 件。順序違反は 409。未知 type は 400。

`workDate` / `at`（`HH:mm`、Asia/Tokyo）を付けると**事後打刻**（`source=manual`）。省略時はサーバー現在時刻で `source=web`。クライアントの壁時計を信用しない通常打刻と、忘れ打刻用の明示日付を分けている。

### POST `/v1/me/days/{date}/apply-schedule`

所定スケジュール（出・休・退）をその日に一括適用。201 `{ "punches": [ ... ] }`。期間設定の `scheduledStart` / `scheduledEnd` / `breakMinutes` を使う。

### PUT `/v1/me/provisional-days`

仮確定日のマーク（UI／締め前の補助）。詳細はコードとテストを優先。

## 申請・承認・工数・締め

| メソッド | パス | 説明 |
| --- | --- | --- |
| POST/GET | `/v1/requests` | 申請。休暇は `leaveKind`（paid／am_half／pm_half／absence 等） |
| GET | `/v1/approvals` | 上長 inbox |
| POST | `/v1/requests/{id}/decision` | `{ "approve": true\|false }` |
| POST/GET | `/v1/allocations` | 工数按分（合計 ≤ その日の勤務分） |
| POST | `/v1/months/{month}/close` | 上長締め。締め後の打刻は 409 |
| GET | `/v1/reminders/unpunched?date=` | 未打刻一覧（メール送信なし） |

## CSV／PDF／org 期間設定

### GET `/v1/months/{month}/export.csv`

クエリ: `profile`（省略時 org 既定または `minutes-v1`）、`header`、`columns`（カスタム列）。応答ヘッダ `X-Attendance-Export-Contract` にプロファイル id。上長のみ。

| id | 性質 |
| --- | --- |
| `minutes-v1` | P16 向け既定（engagement／worksite 列含む） |
| `erp-generic-ja` | 非公式例示 |
| `mf-attendance-punch-v1` | MF クラウド勤怠 日次打刻（公式ヘルプ列） |
| `freee-hr-monthly-v1` | freee 月次列。**残業・休日内訳は 0** |
| `custom` | 列順カスタム |

KOT／ジョブカン／奉行の固定公式スキーマは未作成。

### GET `/v1/months/{month}/timesheet.pdf`

タイムシート PDF。任意クエリ `employeeSub`（上長が部下指定）。

### GET/PUT `/v1/org/period-settings`

```json
{
  "orgId": "org-demo-a",
  "periodAnchorDay": 1,
  "closeByDay": 5,
  "csvProfileId": "minutes-v1",
  "csvIncludeHeader": true,
  "csvColumns": [],
  "scheduledStart": "09:00",
  "scheduledEnd": "18:00",
  "breakMinutes": 60,
  "breakMode": "fixed",
  "scheduledNetMinutes": 480
}
```

`periodAnchorDay`（1–28）で月次期間の起点。`closeByDay` は締め期限の目安（0 は未設定扱いで締め前チェックが厳しくなる場合あり）。所定時刻は事後打刻の apply-schedule と PDF 表示に使う。

### GET `/v1/org/csv-profiles`

カタログ一覧（`fidelity` / `sourceUrl` 付きベンダー行を含む）。

## SES／客先（段階 A–C）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/v1/months/{month}/handoff.csv` | 就業側→雇用主向け `worksite-minutes-v1`。ヘッダ `X-Attendance-Handoff-Contract` |
| POST | `/v1/months/{month}/handoffs` | `Content-Type: text/csv`。雇用主側取り込み。クエリ `sourceHint` |
| GET | `/v1/months/{month}/handoffs` | receipt 一覧（金額列なし） |
| GET | `/v1/worksite/visible-members` | 他社ゲスト含む読み取り名簿 |

handoff CSV ヘッダ例: `sub,worksiteCode,worksiteName,workDate,workMinutes,breakMinutes,status`。金額・税列は拒否。
