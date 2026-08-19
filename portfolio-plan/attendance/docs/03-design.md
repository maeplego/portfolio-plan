# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | attendance（GitHub: [pf-attendance](https://github.com/maeplego/pf-attendance)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 構成

```
apps/api   Spring Boot 3.4 / Java 21。ドメイン純関数と店舗
apps/web   Next.js。ブラウザから API を直接呼ぶ（打刻ホームと /calendar）
deploy     Postgres 16（store=jpa のとき）
```

`attendance.store=memory`（テスト既定）では DataSource を起動しない。Compose は `jpa`。ローカル起動の正は Compose。Kubernetes 用マニフェストは別リポジトリの束ね役から参照する場合がある。

## 2. 打刻はイベント

`punches` は追記のみ。行を上書きして「なかったこと」にしない。修正は将来の補正イベント。日次・月次の分数は読み取り時に `DailyHoursCalculator` が計算する（キャッシュテーブルは未作成）。

## 3. 時刻

`Clock` は UTC。`WorkDates.of(instant)` が Asia/Tokyo の日付を付ける。テストは `Clock` を差し替えて 23:59 / 00:00 を止める。

クライアント JSON の未知フィールド（`punchedAt` 含む）は Jackson が落とす。サーバー時刻が正。

## 4. 分数

`Duration` の秒を 60 で割って切り捨てる。浮動小数の時間は持たない。月次 API は各暦日に同じ計算を繰り返す。

## 5. 認可

`X-Dev-User-Sub` → `employees.sub`。クエリは常に自分の `employee_id`。他人の ID を URL に載せない。月次も同じ隔離（他従業員は全日 0）。

[pf-identity](https://github.com/maeplego/pf-identity) は未配線。`ATTENDANCE_DEV_AUTH=false` では全 `/v1` が 401。

## 6. 日勤のみ

勤務日は各打刻の Tokyo 日付。前日に出勤したまま 00:00 を越えても、新しい日の状態は `absent` から始まる。夜勤の「勤務日」明示はフィールドを足してからにする。中途半端に継続しない。
