# P15 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P15 habit-tracker |
| 対象スライス | 1 |
| 最終更新 | 2026-08-19 |

## 1. リポジトリ

| リポジトリ | 役割 | K8s |
| --- | --- | --- |
| `pf-habit-mobile` | Expo、expo-sqlite、domain 純関数 | 載せない |
| `pf-habit-api` | Hono、Postgres、Compose | このスライスでは未着手 |

共有は契約（暦日文字列と JSON 形）だけ。ストリーク実装はモバイル側が正。API は保存だけ。

## 2. 「今日」

`Intl.DateTimeFormat` の `formatToParts` で IANA TZ → 暦日。日加算は UTC の年月日フィールドをカレンダーとして使う（24h 加算をしない。DST で日付が飛ばない）。

## 3. SQLite

`habits` と `habit_logs`（PK: habit_id + local_date）。空なら架空シード。

## 4. API 認可

`X-Dev-User-Sub` → `users.sub`。habit 参照は常に `user_id` 付き。メモリ実装で隔離テスト。

## 5. TZ 変更

既存 `local_date` は書き換えない。新しい「今日」だけが新しい TZ で決まる。

## 6. 同期

スライス 1 のモバイルは API を呼ばない。衝突解消（LWW）は未実装。
