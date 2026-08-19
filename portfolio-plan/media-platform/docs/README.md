# P03 media-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P03 media-platform |
| 対象スライス | presign + complete + 共有リンク + processor。AWS Lambda 本番は計画ではなく非目標に近い（ローカル Redis + worker） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-media` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書 |
| [02-specification.md](02-specification.md) | 外部仕様書 |
| [03-design.md](03-design.md) | 内部設計書 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | API 仕様書 |
| [06-diagrams.md](06-diagrams.md) | 図表 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| Garage + presign + complete + クォータ | 実装済み | 要件、API |
| 共有リンク | 実装済み | 仕様、TS |
| processor（thumb / detail） | 実装済み | 設計、シーケンス |
| ドライブ UI | 実装済み | 仕様の画面 |
| S3→SQS→Lambda | 未実装（計画）。ローカルは Redis + worker | 非目標にしないが「できた」と書かない |
