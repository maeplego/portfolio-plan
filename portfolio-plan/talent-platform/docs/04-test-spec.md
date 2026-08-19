# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | talent-platform（GitHub: [pf-talent-api](https://github.com/maeplego/pf-talent-api)、[pf-talent-web](https://github.com/maeplego/pf-talent-web)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 自動化は製品リポジトリの vitest。この表と食い違ったらテストかこの文書を直す |

## 方針

- HTTP 単体は `MemoryStore`（`app.request`）。
- Postgres 結合は `TALENT_DATABASE_URL` が届くときだけ。届かないときは skip（未実行を成功扱いにしない）。
- Compose の実行系は Postgres。メモリ店舗だけの常時運用は想定しない。

## webhook と状態

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-W01 | 正しいヘッダと `externalRef` | 200、応募ステータス `interview`、`interviewBookingId` |
| TS-W02 | 面接 event type の provision | Bearer 付きで pf-calendar の内部 API へ `externalRef = job.id` |
| TS-S01 | applied → interview | 409 `invalid_transition` |
| TS-S02 | applied → document_passed | 200 |

## プロフィール・求人・検索

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-P01 | PUT/GET プロフィール | 200 |
| TS-P02 | 未知の sub | 404 |
| TS-J01 | 求人作成後の一覧 | 取得できる |
| TS-J02 | skills / 年収 / remote | 保持される |
| TS-F01–F04 | employmentType / remote / skills / salary | 条件に合う published のみ |
| TS-F05 | `q=kubernetes` | title/description に含む |
| TS-F06 | 日本語部分一致 `q=エンジ` | FTS だけでは足りないため trigram / ILIKE。Postgres 結合でも同じ |

## 保存検索・枠・類似

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-SS01 | 作成と一覧 | 201 と保存内容 |
| TS-SS02 | run | `matchedJobs` と `lastRunAt` |
| TS-SS03 | 未知 id の run | 404 |
| TS-I01 | 書類通過後の枠 | pf-calendar の `starts` |
| TS-I02 | applied で枠 | 409 `invalid_state` |
| TS-R01 | pf-recommend 未接続 | `source=fallback`（スキル重なり） |
| TS-R02 | 推薦が成功し重なりが同等以上 | `source=recommend` |
| TS-R03 | 推薦の重なりが明らかに劣る | `source=fallback`（閉じる） |

## 一覧 ACL と UI

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-L01 | 公開求人 GET | 200 |
| TS-L02 | 無い id | 404 |
| TS-L03 | 他社の応募一覧 | 403 |
| TS-L04 | 他候補者の応募一覧 | 403 |
| TS-UI01 | API 未接続 | Web は落ちず 503 相当のメッセージ |
| TS-UI02 | `?user=` なし | ゲスト相当を出さない |
| TS-UI03 | 手動: 履歴書の見え方 | 当事者だけ全文。他社 403 |
| TS-UI04 | 手動: 保存検索と枠 | 未接続なら「カレンダー未接続」。予約は pf-calendar の公開ページ |
