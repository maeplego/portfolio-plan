# P10 talent-platform — 要件定義

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 学習用最小：jobs + applications、P05 `calendar.booking.confirmed` webhook 受信と status 更新 |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | `../DESIGN.md` と `../pf-talent-api` のテスト・コード、次に本書類 |

## 目的

- 求人（jobs）と応募（applications）を最小モデルで保持する。
- P05 予約確定（`calendar.booking.confirmed`）を webhook 受信し、応募ステータスを `interview` に更新する。
- MVP では検索・推薦・画面は扱わない（次スライスで拡張）。

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

## 非機能要件

- 学習用 MVP。プロダクション品質（永続化DB、認可、冪等制御）は省略する。
- webhook 入力はスキーマで検証し、不正は `400 invalid_request`。
- 失敗時に「秘密をログに出さない」。

## 含まない機能要件（非目標）

- 求人検索・ページング・推薦（P07）
- 候補者/企業認証（P01 の OIDC 連携は後続）
- outbox 配信の厳密な冪等性（P05 が 201 と outbox で担保する前提）

