# P09 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P09 attendance |
| 対象スライス | 1 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 1. 構成

```
apps/api   Spring Boot 3.4 / Java 21。ドメイン純関数 + 店舗
apps/web   Next.js。ブラウザから API を直接呼ぶ
deploy     Postgres 16（store=jpa のとき）
```

`attendance.store=memory`（テスト既定）では DataSource を起動しない。Compose は `jpa`。

## 2. 打刻はイベント

`punches` は追記のみ。修正は後スライスの補正イベント。日次サマリーは読み取り時に `DailyHoursCalculator` が計算する（キャッシュテーブルは未作成）。

## 3. 時刻

`Clock` は UTC。`WorkDates.of(instant)` が Asia/Tokyo の日付を付ける。テストは `Clock` を差し替えて 23:59 / 00:00 を止める。

クライアント JSON の未知フィールド（`punchedAt` 含む）は Jackson が落とす。

## 4. 分数

`Duration` の秒を 60 で割って切り捨てる。浮動小数の時間は持たない。

## 5. 認可

`X-Dev-User-Sub` → `employees.sub`。クエリは常に自分の `employee_id`。他人の ID を URL に載せない（このスライスに他人の日次 API は無い）。

P01 は未配線。`ATTENDANCE_DEV_AUTH=false` では全 `/v1` が 401。

## 6. 日勤のみ

勤務日は各打刻の Tokyo 日付。前日に出勤したまま 00:00 を越えても、新しい日の状態は `absent` から始まる。夜勤の「勤務日」明示は次にやるならフィールドを足す。中途半端に継続しない。
