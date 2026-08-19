# P10 talent-platform — 内部設計

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小 + 検索フィルタ + 保存検索 + 一覧 ACL（in-memory） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-talent-api` |

## 構成

- `pf-talent-api`：Hono で API と webhook を同一サービス内に持つ。
- `pf-talent-web`：Next.js（ポート 3010）。`TALENT_API_URL` と `X-Dev-User-Sub`。
- overlay C では Ingress で `talent.localhost` を web、`talent-api.localhost` を API に分ける。
- 永続化は MVP では `MemoryStore`。検索は API 内部分一致。platform Postgres へは移行しない。

## データモデル（MVP）

- `Job`
  - `id`, `employerSub`, `title`, `status`
- `Application`
  - `id`, `jobId`, `candidateSub`, `resumeSnapshot`
  - `status`: `applied` | `document_passed` | `interview` | `rejected`
  - webhook 連携キー: `calendarExternalRef`
  - `interviewBookingId`（webhook 時にセット）
- `SavedSearch`
  - `id`, `candidateSub`, `name`
  - 検索条件: `query`, `employmentType`, `remote`, `skills`, `salaryMin`, `salaryMax`
  - `lastRunAt`

## 保存検索の実行

1. 候補者が検索条件を `SavedSearch` として保存する
2. `run` endpoint で現在の published 求人に対して同条件を再適用する
3. 一致した求人を `matchedJobs` として返す
4. `lastRunAt` を更新する

MVP では別 worker を作らず同期実行とする。将来 `pf-talent-search` や通知バッチへ切り出す前段階。

## P05 面接スロット提示

1. P10 で application を読む
2. `status` が `document_passed` か `interview` であることを確認
3. job を読み、`employerSub` と `job.id` を取得
4. P05 internal API `GET /internal/v1/hosts/:sub/event-types` を呼ぶ
5. `externalRef = job.id` の event type を探す
6. その slug に対して P05 public slots API を呼び、候補スロットをそのまま返す

P10 は slot 計算を再実装しない。P05 を shared capability として利用する。

## P07 類似求人

- `RECOMMEND_API_URL` があるときは P07 `similar-items` を使う
- 無い / 失敗時は P10 内で `skills` overlap を計算してフォールバックする
- P10 側は fallback を持つことで、推薦が未学習・停止中でも求人詳細を壊さない

## webhook 受信処理

1. `X-Calendar-Event-Type` が `calendar.booking.confirmed` であることを検証
2. ペイロードをスキーマ検証
3. `data.externalRef` から application を引く
4. 見つかれば `status=interview`、`interviewBookingId=bookingId` を更新
5. 見つからなければ `matched=false` を返す（P05 側のリトライ前提）

## セキュリティ境界（MVP）

- webhook 認証は MVP ではヘッダ整合のみ。
- P10 → P05 の internal API 呼び出しは `CALENDAR_INTERNAL_TOKEN` の Bearer を使用。
- 応募一覧・企業求人一覧は `X-Dev-User-Sub` がパスの当事者と一致することをサーバーで検証する。UI の非表示は認可ではない。
- `TALENT_DEV_AUTH` 未設定でも当面このヘッダを信じる。OIDC 必須は後続。

## 競合・冪等

- M(V)P：同一 webhook が複数回届いても最終状態が同じ（`interview`）になるため、厳密な冪等テーブルは持たない。

