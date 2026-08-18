# P10 talent-platform — 内部設計

| 項目 | 値 |
| --- | --- |
| プロジェクト | P10 talent-platform |
| 対象スライス | P10 最小（in-memory） |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | `../pf-talent-api` |

## 構成

- `pf-talent-api`：Hono で API と webhook を同一サービス内に持つ。
- 永続化は MVP では `MemoryStore`。

## データモデル（MVP）

- `Job`
  - `id`, `employerSub`, `title`, `status`
- `Application`
  - `id`, `jobId`, `candidateSub`, `resumeSnapshot`
  - `status`: `applied` | `document_passed` | `interview` | `rejected`
  - webhook 連携キー: `calendarExternalRef`
  - `interviewBookingId`（webhook 時にセット）

## webhook 受信処理

1. `X-Calendar-Event-Type` が `calendar.booking.confirmed` であることを検証
2. ペイロードをスキーマ検証
3. `data.externalRef` から application を引く
4. 見つかれば `status=interview`、`interviewBookingId=bookingId` を更新
5. 見つからなければ `matched=false` を返す（P05 側のリトライ前提）

## セキュリティ境界（MVP）

- webhook 認証は MVP ではヘッダ整合のみ。
- P10 → P05 の internal API 呼び出しは `CALENDAR_INTERNAL_TOKEN` の Bearer を使用。

## 競合・冪等

- M(V)P：同一 webhook が複数回届いても最終状態が同じ（`interview`）になるため、厳密な冪等テーブルは持たない。

