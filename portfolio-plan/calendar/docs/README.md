# P05 calendar — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P05 calendar |
| 対象スライス | 1–3 実装済み（slot-engine、ホスト API、公開 slots/book）。4–7 は計画 |
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
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面遷移（計画含む）、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 slot-engine | 実装済み | 要件の時刻、仕様のスロット生成、設計の Temporal、テスト TS-E* |
| 2 イベントタイプ API | 実装済み | 仕様のホスト操作、API `/v1/*` |
| 3 公開 book + exclusion | 実装済み | 仕様の予約、設計の TOCTOU、シーケンス、TS-B* |
| 4 Next.js UI + P01 OIDC | 未実装 | 画面遷移は計画。受け入れに入れない |
| 5 キャンセル + ICS | 未実装 | キャンセルトークンは発行済み。取消 API は未実装 |
| 6 リマインドワーカー | 未実装 | |
| 7 P10 内部 API | 未実装 | |
