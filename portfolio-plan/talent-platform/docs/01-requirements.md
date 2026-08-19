# P10 talent-platform — 要件定義

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小 + プロフィール + 検索フィルタ + 保存検索 + 一覧 ACL |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../DESIGN.md` と `../pf-talent-api` のテスト・コード、次に本書類 |

## 目的

- 求人（jobs）と応募（applications）を最小モデルで保持する。
- P05 予約確定（`calendar.booking.confirmed`）を webhook 受信し、応募ステータスを `interview` に更新する。
- 検索と保存検索は最小形。画面は次スライス（`pf-talent-web`）で扱う。

## アクター

- `employer`：求人を作成する（認証は MVP では省略）
- `candidate`：応募を作成する（認証は MVP では省略）
- P05：予約完了イベント `calendar.booking.confirmed` を webhook で通知する（認証はヘッダ整合のみ）

## 含む機能要件

1. 求人作成（`POST /v1/jobs`）
2. 応募作成（`POST /v1/jobs/:id/applications`）
3. 応募参照（`GET /v1/applications/:id`）
4. 応募ステータス更新（`PATCH /v1/applications/:id/status`）
5. P05 契約に従い、P05 の `event_type.externalRef`（MVP では job id）を application に紐付け（`PUT /v1/applications/:id/calendar-link`）
6. webhook 受信（`POST /webhooks/calendar`）
   - `X-Calendar-Event-Type: calendar.booking.confirmed` を必須とする
   - `data.externalRef` が一致する application を `interview` に更新
   - 該当なしなら `200 { ok: true, matched: false }`（リトライ可能性のため）
7. P05 internal API を呼ぶ「イベントタイプ自動プロビジョン」学習用 endpoint
   - `POST /v1/jobs/:id/provision-interview-event-type`
   - `CALENDAR_INTERNAL_TOKEN` と `CALENDAR_API_URL` が必要
   - `externalRef = job.id` で `interview` 用 event type を作る
8. 候補者は保存検索を登録できる
   - `POST /v1/saved-searches`
   - `GET /v1/candidates/:sub/saved-searches`
9. 保存検索の新着マッチを手動実行できる
   - `POST /v1/saved-searches/:id/run`
   - 返り値に `matchedJobs` と `matchedCount` を含む
10. 書類通過後の応募に対して P05 の面接候補スロットを提示できる
   - `GET /v1/applications/:id/interview-slots`
   - `document_passed` または `interview` の応募のみ
   - job の `employerSub` と `job.id` を使って P05 の event type を特定する
11. ✅ 類似求人を返せる
   - `GET /v1/jobs/:id/similar`
   - P07 recommend API があればそれを優先
   - 未接続時は skills overlap でフォールバック
12. ✅ ファセット件数と管理通報の最小形
   - `GET /v1/jobs/facets`（同じフィルタ条件を入力に応じて集計）
   - `POST /v1/reports` / `GET /v1/reports`（管理レビュー用の通報保存）
13. ✅ 画面が呼ぶ一覧と詳細
   - `GET /v1/jobs/:id`
   - `GET /v1/employers/:sub/jobs`
   - `GET /v1/jobs/:id/applications` / `GET /v1/candidates/:sub/applications`
   - 応募一覧は `X-Dev-User-Sub` が当事者と一致しないと 403
14. ✅ 架空求人シード（8〜12 件、実在企業名禁止）

## 非機能要件

- 学習用 MVP。永続化 DB と OIDC 必須は省略する。応募一覧は開発ヘッダでサーバー側検証する。
- webhook 入力はスキーマで検証し、不正は `400 invalid_request`。
- 失敗時に「秘密をログに出さない」。

## 含まない機能要件（非目標）

- 求人検索・ページング・推薦（P07）
- 候補者/企業認証（P01 の OIDC 連携は後続）
- outbox 配信の厳密な冪等性（P05 が 201 と outbox で担保する前提）

