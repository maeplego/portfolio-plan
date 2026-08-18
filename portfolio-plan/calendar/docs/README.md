# P05 calendar — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P05 calendar |
| 対象スライス | 1–10 実装済み（slot-engine → Postgres integration） |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | `../pf-calendar` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。ゲスト・ホストから見た振る舞いと時刻契約 |
| [03-design.md](03-design.md) | 内部設計書。二段構え、TOCTOU、データ、モジュール |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面遷移、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 slot-engine | 実装済み | 要件の時刻、仕様のスロット生成、設計の Temporal、テスト TS-E* |
| 2 イベントタイプ API | 実装済み | 仕様のホスト操作、API `/v1/*` |
| 3 公開 book + exclusion | 実装済み | 仕様の予約、設計の TOCTOU、シーケンス、TS-B* |
| 4 Next.js UI + OIDC 準備 | 実装済み | 仕様 §7 画面、05-api ホスト認証 |
| 5 キャンセル + ICS | 実装済み | 05-api 公開 cancel/ics、06-diagrams 状態 |
| 6 リマインドワーカー | 実装済み | 03-design §8、Compose Mailhog |
| 7 P10 内部 API | 実装済み | 05-api `/internal/v1/*`、DESIGN P10 契約 |
| 8 booking.confirmed | 実装済み | outbox + `CALENDAR_WEBHOOK_URL` |
| 9 OpenAPI | 実装済み | `packages/openapi`、`GET /openapi.yaml` |
| 10 Postgres TS-M01 | 実装済み | `postgres.integration.test.ts`（DB 未起動時 skip） |
