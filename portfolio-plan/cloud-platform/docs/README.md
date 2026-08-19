# P02 cloud-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | o11y Compose、計装契約、連携 overlay A/B/C/D/E/F、Terraform モジュール（apply は非目標） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-cloud-o11y` / `../pf-cloud-k8s` / `../pf-cloud-aws` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

このポートフォリオは **AWS へ本番デプロイしない。** ローカルデモは各製品 Compose と Docker Desktop Kubernetes（`pf-cloud-k8s`）。Terraform は面接で 3-tier を説明するモジュールであり、`apply` は残作業でも目標でもない。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。レビュアとアプリから見た 2 モード |
| [03-design.md](03-design.md) | 内部設計書。overlay、3-tier モジュール、計装、state |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。health/ready、OTLP、demo-api |
| [06-diagrams.md](06-diagrams.md) | ユースケース、構成、シーケンス |

kustomize の URL 一覧と overlay 切替は運用ランブックとして `../pf-cloud-k8s/docs/` に残す。採用担当者は `portfolio-plan/REVIEW.md`。DESIGN と重複する方針は本ディレクトリを正とする。

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 o11y Compose | 実装済み | 要件 FR-観測、仕様の Grafana、05-api demo-api |
| 2 計装ガイドライン | 実装済み | 設計の計装、05-api 契約 |
| 3 連携デモ文書 | 実装済み | `integration-demo.md`。本索引は追随 |
| 4 foundation overlay | 実装済み | 仕様の連携モード、図表 |
| 5 overlay C scheduling-talent | 実装済み | k8s ランブック、integration-demo |
| 6 overlay B collab + P11 portal | 実装済み | `portal.localhost`。scanner は非搭載 |
| 7 overlay E content | 実装済み | P08。P11 は計画 |
| 8 overlay F ops | 実装済み | P09 / P12 / P14 / P15 API。Expo は非搭載 |
| 8b overlay D commerce | 実装済み | P06 フル + P07。P11/P12/P13 は計画 |
| 9 Terraform モジュール + GitHub OIDC | 実装済み（モジュール） | 設計の 3-tier。apply は計画ではなく非目標 |
| 10 学習アカウントへ 3-tier 載せる | **非目標** | README のコスト・destroy のみ |
| 11 障害注入手順の文書化 | 計画 | o11y debug エンドポイントは実装済み。P12 題材は後続 |
