# P09 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P09 attendance |
| 対象スライス | 1。自動化は `mvn test`（apps/api） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリの JUnit。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| WorkDates / Minutes / DailyHours / PunchRules | DB なし | 日境界と整数分 |
| AttendanceService | メモリ店舗 + 差し替え Clock | 打刻と他人隔離 |
| HTTP | MockMvc + メモリ | 401、無視する punchedAt、480 分 |

exploit / PoC は書かない。実在個人を fixture に置かない。

## 2. 日境界

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-D01 | 2026-08-18T14:59:00Z | 勤務日 2026-08-18 |
| TS-D02 | 2026-08-18T15:00:00Z | 勤務日 2026-08-19 |
| TS-D03 | 同従業員が両方に出勤 | 各日 1 件。混ざらない |

## 3. 日次分数

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-H01 | 09:00–18:00 相当 + 1h 休憩 | work 480、break 60、clocked_out |
| TS-H02 | 出勤後に休憩開始のみ（asOf なし） | work 180、break 0、on_break |
| TS-H03 | 同上 asOf=退勤相当 | break 360 |
| TS-H04 | 50 秒の在社 | work 0 |
| TS-H05 | 休憩中の退勤イベントを計算に載せる | PunchConflictException |

## 4. 打刻 HTTP

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-P01 | `/health` `/ready` | 認証なし 200 | |
| TS-P02 | ヘッダなし POST | 401 | |
| TS-P03 | punchedAt=1999 を付ける | サーバーの 2026-08-19T00:00:00Z | FR-01 |
| TS-P04 | 休憩込み 4 打刻のち GET daily-summary | 480 / 60 | FR-03 |
| TS-P05 | sato.mei の同日 | punches 空 | FR-05 |
| TS-P06 | type=teleport | 400 | |
| TS-P07 | 同日二重出勤 | 409（サービス層） | FR-04 |

## 5. 未自動化

- Compose 実機の画面操作
- Postgres / Testcontainers（store=jpa）
- 締め後 409
