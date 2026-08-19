# P06 commerce-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | 1 実装済み（モジュラモノリスの購入〜在庫不足） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-commerce` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。購入者と API から見た振る舞い |
| [03-design.md](03-design.md) | 内部設計書。モジュール境界、引当、補償 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 購入〜在庫不足 | 実装済み | 要件 FR、仕様のチェックアウト、設計の引当、TS-C* |
| 2 catalog/inventory/order 抽出 | 計画 | DESIGN 実装順 2。K8s / overlay D は禁止のまま Compose で切る |
| 3 注文イベントストア | 計画 | idea 25。Given/When/Then |
| 4 payment/notify + outbox | 計画 | |
| 5 ops-web グリッド | 計画 | idea 06 |
| 6 GraphQL BFF + DataLoader | 計画 | idea 24 |
| 7 P03 / P07 / P02 kind | 計画 | |
