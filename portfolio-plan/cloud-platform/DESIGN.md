# P02 cloud-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/16-terraform-three-tier-infra.md`
- `portfolio-idea/17-kubernetes-microservices.md`
- `portfolio-idea/18-observability-stack.md`

特定アプリを載せる作業では、そのアプリの `DESIGN.md` も渡す。

## 対応アイデア

- 16 Terraform で構築する 3-tier Web 基盤
- 17 Kubernetes 上のマイクロサービス基盤
- 18 ログ・メトリクス監視基盤

## 目的

「アプリの箱」と「見る手段」を標準化する。各製品リポジトリに VPC や Grafana をコピーしない。P06 のような複数プロセス製品は K8s、P08 / P09 のような 1 API + Web は AWS 3-tier（または同等の安いランタイム）に載せる。

観測は **どの実行基盤でも同じ計装** にする。アプリは OTLP を Collector に送るだけ。

## リポジトリ構成（ポリレポ）

Terraform と K8s と観測スタックはライフサイクルが違う。state の権限も違う。ポリレポ。

| リポジトリ | 役割 |
| --- | --- |
| `pf-cloud-aws` | アイデア 16。VPC、ALB、ECS または ASG、RDS、GitHub OIDC、モジュール化 |
| `pf-cloud-k8s` | アイデア 17。kind 用ベースマニフェスト、kustomize overlays、アプリは overlay で接続 |
| `pf-cloud-o11y` | アイデア 18。Collector、Prometheus、Loki、Tempo、Grafana の Compose と K8s マニフェスト |
| `pf-cloud-docs` | 構成図、コスト、destroy 手順、SLO の書き方。コードを持たないでも可 |

`pf-cloud-k8s` に P06 の Deployment 本文を全部は書かない。P06 側に `deploy/` を置き、こちらは **ベース（Ingress, 制限, 観測 sidecar 規約）** を提供する。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| IaC | Terraform, AWS provider。`tflint` + `tfsec`/`checkov` |
| コンテナ基盤 | kind + Ingress NGINX。kustomize。Helm は kube-prometheus など第三者だけ |
| 観測 | OpenTelemetry Collector、Prometheus、Grafana、Loki、Tempo（または Jaeger） |
| CI | GitHub Actions。AWS は OIDC。永久キー禁止 |
| サンプル計装 | Go または Node の最小 `/health` `/work` アプリを `pf-cloud-o11y` に同梱 |

## 設計思想

- **アプリ先、基盤後。** 空の Terraform を完成扱いしない。載せる対象（最初は P08 かサンプル）が決まってから apply する
- **ローカルが正。** kind / Compose で再現できない「本番だけ魔法」を作らない
- **コストを設計に含める。** NAT 二重、多 AZ RDS を個人課金で再現しない。選択理由を README に書く
- **症状ベースのアラート。** CPU 80% ではなく 5xx 比率とレイテンシ
- **K8s は必要になったから使う。** 単一プロセスの家計簿をクラスタに載せない

## 3 アイデアの分担

| アイデア | このプロジェクトでの実体 |
| --- | --- |
| 16 | `pf-cloud-aws` モジュール。最初の適用先は P08 または P09 |
| 17 | `pf-cloud-k8s` のベース。最初の適用先は P06 |
| 18 | `pf-cloud-o11y`。全アプリの標準。フェーズ 0 で Compose を先に完成 |

## 実装順序

1. `pf-cloud-o11y` の Compose。サンプルアプリで RED ダッシュボードとトレース
2. 計装ガイドライン（ログ JSON キー名、`http.route` の正規化、禁止ラベル）
3. kind クラスタに同じ観測を載せる
4. P06 がサービス 3 つ以上になったら `pf-cloud-k8s` のベース + P06 overlay
5. GitHub OIDC と `pf-cloud-aws` モジュール
6. 安価な環境に 3-tier を 1 アプリ載せる。請求アラーム必須
7. 障害注入手順（高レイテンシ、5xx、pod kill）を文書化。P12 のシナリオの素材になる

## 実装上の注意点

- Grafana をインターネットに素通ししない
- Secret を Git の Kubernetes Secret 平文で置かない。kind では `.env`、本番では外部注入
- Prometheus ラベルに user id や注文 id を入れない（カーディナリティ）
- Terraform state は S3 + lock。個人アカウントでもローカル state を「完成」にしない
- `0.0.0.0/0:22` を開けない。Session Manager または使わない
- 月額見積と `destroy` を README の上の方に書く
- 観測スタック自身のディスク使用量（数日保持）を制限する
- アプリ側は Collector 経由。各アプリが Jaeger に直接送ると P02 の意味が消える

## 他プロジェクトとの契約

アプリが守ること:

- `GET /health`（liveness）、`GET /ready`（依存確認）
- OTLP HTTP または gRPC を環境変数 `OTEL_EXPORTER_OTLP_ENDPOINT` で受ける
- ログは JSON。`trace_id`, `span_id`, `service`

P12 への契約: アラート webhook の JSON 形を 1 つ決め、署名検証できるようにする。P12 が未完成なら Discord でもよい。

## デモ

- Compose で Grafana を開き、エラー注入するとトレースがつながること
- kind で pod を消しても Deployment が戻ること
- Terraform plan のスクリーンショット（秘密マスク）

## 非目標

- サービスメッシュ（Istio）
- マルチリージョン
- 本番級の長期保持と課金最適化のやり込み
