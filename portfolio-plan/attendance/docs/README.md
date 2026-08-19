# P09 attendance — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P09 attendance |
| 対象スライス | 1 実装済み（従業員・打刻・日次労働時間）。2 以降は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-attendance` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。打刻と日境界 |
| [03-design.md](03-design.md) | 内部設計書。イベント、整数分、Tokyo |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 打刻と日次（休憩控除） | 実装済み | 要件 FR、仕様の日境界、API、TS-D*/P* |
| 2 月次カレンダー UI | 計画 | DESIGN 実装順 2 |
| 3 修正・休暇申請と承認 | 計画 | 実装順 3 |
| 4 工数按分 | 計画 | 実装順 4 |
| 5 月次締めと CSV | 計画 | 実装順 5。締め後 409 はまだ無い |
| 6 未打刻リマインド / P01 | 計画 | 実装順 6–7 |
| overlay F | 実装済み | `pf-cloud-k8s` `f-ops`。P01 OIDC は未配線 |
