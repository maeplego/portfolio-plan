# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | talent-platform（GitHub: [pf-talent-api](https://github.com/maeplego/pf-talent-api)、[pf-talent-web](https://github.com/maeplego/pf-talent-web)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 構成

- `pf-talent-api`: Hono。求人・応募・webhook を同一プロセスに持つ。
- `pf-talent-web`: Next.js（ポート 3010）。`TALENT_API_URL` と `X-Dev-User-Sub`。
- 永続化の正は **Postgres**。Compose は専用 Postgres。Kubernetes overlay では platform Postgres の DB 名 `talent`。
- 単体テストだけ `MemoryStore`。Compose をメモリ店舗のまま運用しない。
- 検索（Postgres）: generated `jobs.search_tsv`（`simple`）と `pg_trgm` GIN。OpenSearch は未接続。
- 検索（MemoryStore）: 部分一致。テスト用。

Ingress 例: `talent.localhost` が Web、`talent-api.localhost` が API。

## データモデル

- `Job`: `id`, `employerSub`, `title`, `status`、雇用形態・リモート・年収範囲・skills など
- `Application`: `id`, `jobId`, `candidateSub`, `resumeSnapshot`, `status`（`applied` | `document_passed` | `interview` | `rejected` | `offered`）、`calendarExternalRef`, `interviewBookingId`
- `SavedSearch`: 候補者の条件と `lastRunAt`

応募ステータスの `interview` は選考段階。枠の計算は [pf-calendar](https://github.com/maeplego/pf-calendar) 側。

## 保存検索

1. 条件を保存する
2. `run` で published に再適用する
3. `matchedJobs` を返し `lastRunAt` を更新する

別ワーカーは作らない。将来 indexer を分ける前段階。

## カレンダー連携

1. 応募を読む
2. `document_passed` または `interview` を確認する
3. 企業 `sub` と `job.id` で pf-calendar の内部 API から event type を探す（`externalRef = job.id`）
4. 公開 slots をそのまま返す

`CALENDAR_INTERNAL_TOKEN` の Bearer が無いとスロット API は 503。

## 類似求人

`RECOMMEND_API_URL` があれば [pf-recommend](https://github.com/maeplego/pf-recommend) の `similar-items` を呼ぶ。失敗時、および推薦リストのスキル重なりがローカル順位より劣るときは **スキル重なりへ閉じる**。検索本体を推薦停止で壊さない。

## webhook

同一 `calendar.booking.confirmed` が複数回来ても最終状態は `interview`。専用の冪等テーブルは持たない。見つからなければ `matched=false`（送信側の再送前提）。

## 認可

- webhook はヘッダ整合（署名なし）
- 一覧は `X-Dev-User-Sub`（`TALENT_DEV_AUTH=true`）または Bearer がパスの当事者と一致すること。UI の非表示は認可ではない
- Compose は開発ヘッダ既定 true。Kubernetes の Web は OIDC 必須にする構成がある
