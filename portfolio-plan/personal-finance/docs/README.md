# P14 personal-finance — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P14 personal-finance |
| 対象スライス | 1 実装済み + CSV 入出力。IndexedDB / 同期 / P01 は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-finance` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。ユーザーと API から見た振る舞い |
| [03-design.md](03-design.md) | 内部設計書。整数円、認可、シード |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面遷移、シーケンス、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 オンライン CRUD + グラフ + インストール | 実装済み | 要件 FR、仕様の月次、API、TS-M*/H* |
| 2 IndexedDB とオフラインキュー | 計画 | DESIGN 実装順 3。Service Worker はシェルのみ |
| 3 同期 API / LWW + tombstone | 計画 | 実装順 4。削除はいまハードデリート |
| 4 CSV | 実装済み | `GET /v1/export.csv` `POST /v1/import`。整数円。カテゴリ名突合 |
| 4 残り P01 / ダークモード / アカウント削除 | 計画 | 実装順 6 |
| overlay F | 実装済み | `pf-finance/deploy/k8s/`。Compose が正 |
