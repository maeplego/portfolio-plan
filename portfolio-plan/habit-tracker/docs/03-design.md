# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | habit-tracker（GitHub: [pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile)、[pf-habit-api](https://github.com/maeplego/pf-habit-api)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. リポジトリ

| リポジトリ | 役割 | Kubernetes |
| --- | --- | --- |
| `pf-habit-mobile` | Expo、expo-sqlite、domain 純関数、統計画面 | 載せない |
| `pf-habit-api` | Hono、Postgres、Compose | 載せない |

共有は契約（暦日文字列と JSON 形）だけ。ストリークと統計の計算はモバイル側が正。API は保存だけ。モバイルはいま API を呼ばない。

## 2. 「今日」

`Intl.DateTimeFormat` の `formatToParts` で IANA TZ → 暦日。日加算は UTC の年月日フィールドをカレンダーとして使う（24h 加算をしない。DST で日付が飛ばない）。

## 3. SQLite

`habits` と `habit_logs`（PK: habit_id + local_date）。空なら架空シード。統計は `lastNDaysStats` が完了日集合から 30 日窓を切る。

## 4. API 認可

`X-Dev-User-Sub` → `users.sub`。habit 参照は常に `user_id` 付き。メモリ実装で隔離テスト。Compose がデモ起動の正。

## 5. TZ 変更と同期

既存 `local_date` は書き換えない。新しい「今日」だけが新しい TZ で決まる。衝突解消（LWW）は未実装。
