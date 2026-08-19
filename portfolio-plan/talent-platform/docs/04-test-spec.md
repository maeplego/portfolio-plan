# P10 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小 + 検索 + 保存検索 + 一覧 ACL |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリの vitest。本表と食い違ったらテストを直すか本表を追随 |

## 方針

- HTTP 単体は `MemoryStore`（`app.request`）。
- Postgres 結合は `TALENT_DATABASE_URL` が届くときだけ。届かないときは skip（緑の偽装ではない）。

## テストケース（例）

### TS-W01 webhook により application が interview へ更新される
- `POST /webhooks/calendar` に正しいヘッダとペイロードを送る
- `data.externalRef` に一致する application がある
- 期待: `200`、`status=interview`、`interviewBookingId` がセット

### TS-W02 provision endpoint が P05 internal API を呼ぶ
- `POST /v1/jobs/:id/provision-interview-event-type`
- `CALENDAR_INTERNAL_TOKEN` と `CALENDAR_API_URL` を設定
- 期待: `Authorization: Bearer ...` を付けて P05 の `POST /internal/v1/event-types` へ `externalRef = job.id` で送る

### TS-S01 不正な状態遷移は 409 を返す
- applied → interview は不正: `409 invalid_transition`

### TS-S02 正当な状態遷移は 200
- applied → document_passed: `200`

### TS-P01 候補者プロフィールの upsert / get
- `PUT /v1/profiles/:sub` → `200`
- `GET /v1/profiles/:sub` → プロフィール

### TS-P02 未知のプロフィールは 404
- `GET /v1/profiles/unknown` → `404`

### TS-J01 求人一覧（GET /v1/jobs）
- 求人作成後に一覧で取得

### TS-J02 拡張フィールド付き求人作成
- skills, salaryMin/Max, remote 等が保持される

### TS-F01 employmentType フィルタ
- `GET /v1/jobs?employmentType=contract` → contract のみ

### TS-F02 remote フィルタ
- `GET /v1/jobs?remote=true` → リモート可のみ

### TS-F03 skills フィルタ
- `GET /v1/jobs?skills=Go` → Go を含む求人のみ

### TS-F04 salary フィルタ
- `GET /v1/jobs?salaryMin=5000000` → salaryMax ≥ 5000000 の求人

### TS-F05 q キーワードフィルタ
- `GET /v1/jobs?q=kubernetes` → title/description に含む求人

### TS-F06 日本語の部分一致（q）
- タイトル `バックエンドエンジニア募集` に対し `q=エンジ` がヒットする
- ヒットしない対照求人（デザイナー）は返さない
- Postgres 結合（`TALENT_DATABASE_URL` があるとき）でも同じ。FTS トークン分割では足りないため `pg_trgm` / ILIKE が担当する

### TS-SS01 保存検索の作成と一覧
- `POST /v1/saved-searches` → `201`
- `GET /v1/candidates/:sub/saved-searches` → 保存内容

### TS-SS02 保存検索の実行
- `POST /v1/saved-searches/:id/run` → `matchedJobs`, `matchedCount`
- `lastRunAt` が更新される

### TS-SS03 未知の保存検索実行は 404
- `POST /v1/saved-searches/unknown/run` → `404`

### TS-I01 書類通過後の応募に対して P05 スロットを返す
- `GET /v1/applications/:id/interview-slots`
- internal API で event type を引き、public slots API の `starts` を返す

### TS-I02 書類通過前は面接スロットを引けない
- applied 状態で `GET /v1/applications/:id/interview-slots`
- `409 invalid_state`

### TS-R01 類似求人の fallback
- `GET /v1/jobs/:id/similar`
- P07 未接続時に `skills` overlap で類似求人を返す

### TS-R02 類似求人の recommend 優先
- `RECOMMEND_API_URL` 設定時、P07 `similar-items` の結果を優先する

### TS-L01 公開求人 GET
- `GET /v1/jobs/:id` → `200`

### TS-L02 無い id は 404
- `GET /v1/jobs/missing-id` → `404`

### TS-L03 他社の応募一覧は 403
- `GET /v1/jobs/:id/applications` に別 `X-Dev-User-Sub` → `403`
- 当該 employer なら `200`

### TS-L04 他候補者の応募一覧は 403
- `GET /v1/candidates/:sub/applications` に別ヘッダ → `403`

### TS-UI01 API 未接続でもエラーを表示できる
- `talentFetch` が接続失敗時に `503` と固定メッセージを返す（web は落ちない）

### TS-UI02 開発セッションは user 必須
- `?user=` なしは null（ゲスト相当を出さない）

### TS-UI03 手動: 応募の見え方
- candidate-1 で応募 → `/me/applications` に出る
- employer-1 で応募者一覧に履歴書が出る
- employer-2 で同じ求人の応募者一覧は 403
### TS-UI04 保存検索とスロット
- run で matchedCount を表示
- P05 未接続なら「カレンダー未接続」
- 予約リンクはカレンダー公開ページ（枠 UI を再実装しない）

