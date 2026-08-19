# P06 commerce-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | 2 実装済み + スライス 3 注文イベントストア。overlay D は P06 サブセット |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-commerce` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。購入者と API から見た振る舞い |
| [03-design.md](03-design.md) | 内部設計書。プロセス境界、引当 TX、補償 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。公開 HTTP は gateway |
| [06-diagrams.md](06-diagrams.md) | ユースケース、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 購入〜在庫不足 | 実装済み | 要件 FR、仕様のチェックアウト、設計の引当、TS-C* |
| 2 catalog/inventory/order 抽出 | 実装済み | 同一 `pf-commerce` の `apps/`。Compose 必須 |
| 2b overlay D | 実装済み（サブセット） | P01+P02+P03+P06。P07/P11/P12/P13 は計画 |
| 3 注文イベントストア | 実装済み | idea 25。Given/When/Then。投影 `commerce_orders`。`GET /v1/orders/{id}/events` |
| 4 payment/notify + outbox | 計画 | |
| 5 ops-web グリッド | 計画 | idea 06 |
| 6 GraphQL BFF + DataLoader | 計画 | idea 24 |
| 7 P03 / P07 / P02 kind | 計画 | |
