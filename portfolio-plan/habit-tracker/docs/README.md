# P15 habit-tracker — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P15 habit-tracker |
| 対象スライス | 1 実装済み + 統計画面。ローカル通知・差分同期・P01 は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-habit-mobile` と `../pf-habit-api` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。今日・ストリーク・暦日 |
| [03-design.md](03-design.md) | 内部設計書。TZ、SQLite、API 隔離 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | 同期 API 契約 |
| [06-diagrams.md](06-diagrams.md) | 画面遷移、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 今日チェック + SQLite + ストリーク TZ テスト + 薄い API | 実装済み | 要件 FR、仕様のストリーク、TS-D*/C*、API |
| 2 ローカル通知 | 計画 | DESIGN 実装順 3 |
| 3 統計画面 | 実装済み | 直近 30 日完了率 + ストリーク。`src/domain/stats.ts` |
| 4 モバイルからの差分同期 | 計画 | 実装順 5。いま API は独立デモ |
| 5 P01 PKCE / アイコン / スクリーンショット | 計画 | 実装順 6 |
| overlay F（API のみ） | 実装済み | `pf-habit-api/deploy/k8s/`。Expo は非搭載 |
