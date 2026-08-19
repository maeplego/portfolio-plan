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

「アプリの箱」と「見る手段」を標準化する。各製品リポジトリに VPC や Grafana をコピーしない。P06 のような複数プロセス製品は **ローカルでは K8s overlay**、P08 / P09 のような 1 API + Web は Compose が正。AWS 3-tier モジュールは面接用であり、このポートフォリオは **AWS へ本番 apply しない。**

観測は **どの実行基盤でも同じ計装** にする。アプリは OTLP を Collector に送るだけ。

## リポジトリ構成（ポリレポ）

Terraform と K8s と観測スタックはライフサイクルが違う。state の権限も違う。ポリレポ。

| リポジトリ | 役割 |
| --- | --- |
| `pf-cloud-aws` | アイデア 16。VPC、ALB、ECS または ASG、RDS、GitHub OIDC、モジュール化 |
| `pf-cloud-k8s` | アイデア 17。kustomize overlays（foundation + `portfolio-integration-a` 〜 `f`）。**連携デモの束ね役**。各 `pf-*/deploy/k8s/` を参照 |
| `pf-cloud-o11y` | アイデア 18。Collector、Prometheus、Loki、Tempo、Grafana の Compose と K8s マニフェスト |
| （メタ）`portfolio-plan/cloud-platform/docs/` | 要件・仕様・設計。コストと destroy は `pf-cloud-aws` README |

`pf-cloud-k8s` に P06 の Deployment 本文を全部は書かない。P06 側に `deploy/k8s/` を置き、こちらは **ベース（Ingress, platform 共有リソース, 観測 sidecar 規約）** と **overlay での参照** を提供する。

## ローカルデモの 2 モード

| モード | リポジトリ | 用途 |
| --- | --- | --- |
| **単体 Compose** | 各 `pf-*/deploy/compose.yaml` | その Pxx だけをレビュアが起動。stub / dev 認証可 |
| **連携 K8s** | `pf-cloud-k8s` overlay | P01 + P02 + P03 など横断フロー。Docker Desktop Kubernetes |

手順・URL・デモシナリオの正本: `portfolio-plan/integration-demo.md`。

- **非目標**: 15 Pxx を 1 クラスタで同時フル起動
- **overlay 方針**: `portfolio-integration-a-foundation` 〜 `f-ops` の用途別分割
- **共有 platform**: Postgres（DB 複数）、Redis、Garage/MinIO、OTel Collector、Ingress NGINX
- **イメージ**: 各 `pf-*` の Dockerfile を再利用。overlay は tag / pullPolicy のみ差し替え

### overlay 責務分担

| 置き場所 | 内容 |
| --- | --- |
| `pf-cloud-k8s/deploy/base/` | Ingress クラス、platform Namespace 雛形、共通ラベル |
| `pf-cloud-k8s/deploy/overlays/docker-desktop/` | foundation overlay 用のローカル patch（`imagePullPolicy: IfNotPresent`） |
| `pf-cloud-k8s/deploy/overlays/portfolio-integration/` | P01 + P03 + o11y 最小の foundation ルート |
| `pf-cloud-k8s/deploy/overlays/portfolio-integration-a-foundation/` | 上記の別名（overlay 群 A の正本 ID） |
| `pf-cloud-k8s/deploy/overlays/docker-desktop-a-foundation/` | foundation overlay 用ローカル patch |
| `pf-cloud-k8s/deploy/overlays/portfolio-integration-d-commerce/` | P01 + P03 + P06 + platform。P07/P11/P12/P13 なし |
| `pf-cloud-k8s/deploy/overlays/docker-desktop-d-commerce/` | d-commerce 用ローカル patch |
| `pf-cloud-k8s/deploy/overlays/portfolio-integration-e-content/` | P01 + P03 + P08 + platform。P11 なし |
| `pf-cloud-k8s/deploy/overlays/docker-desktop-e-content/` | e-content 用ローカル patch |
| `pf-cloud-k8s/deploy/overlays/portfolio-integration-f-ops/` | P01 + P09 + P12 + P14 + P15 API + platform |
| `pf-cloud-k8s/deploy/overlays/docker-desktop-f-ops/` | f-ops 用ローカル patch |
| `pf-identity/deploy/k8s/` | idp, admin の Deployment / Service / ConfigMap |
| `pf-media/deploy/k8s/` | api, web, processor |
| `pf-commerce/deploy/k8s/` | catalog, inventory, order, gateway, storefront |
| `pf-talent-api/deploy/k8s/` | talent api |
| `pf-cloud-o11y/deploy/k8s/` | collector, grafana（Compose と同じ設定を K8s 化） |

### Docker Desktop と kind

| 環境 | 用途 |
| --- | --- |
| **Docker Desktop Kubernetes** | レビュア向け連携デモ（Windows/macOS）。overlay ごとに `docker-desktop*` wrapper を用意 |
| **kind** | CI smoke、Linux 開発者。将来 `overlays/kind/` を追加 |

Compose 単体デモは Docker Desktop の **Compose のみ** でも動く。K8s 有効化は連携デモ時だけ必須。


## 技術スタック

| 層 | 採用 |
| --- | --- |
| IaC | Terraform, AWS provider。`tflint` + `tfsec`/`checkov` |
| コンテナ基盤 | kind + Ingress NGINX。kustomize。Helm は kube-prometheus など第三者だけ |
| 観測 | OpenTelemetry Collector、Prometheus、Grafana、Loki、Tempo（または Jaeger） |
| CI | GitHub Actions。AWS は OIDC。永久キー禁止 |
| サンプル計装 | Go または Node の最小 `/health` `/work` アプリを `pf-cloud-o11y` に同梱 |

## 設計思想

- **アプリ先、基盤後。** 空の Terraform を完成扱いしない。モジュールは面接で 3-tier を話すため。`apply` は目標にしない
- **ローカルが正。** Compose と Docker Desktop Kubernetes で再現できない「本番だけ魔法」を作らない
- **コストを設計に含める。** NAT 二重、多 AZ RDS を個人課金で再現しない。選択理由を README に書く
- **症状ベースのアラート。** CPU 80% ではなく 5xx 比率とレイテンシ
- **K8s は必要になったから使う。** 単一プロセスの家計簿をクラスタに載せない

## 3 アイデアの分担

| アイデア | このプロジェクトでの実体 |
| --- | --- |
| 16 | `pf-cloud-aws` モジュール。最初の適用先は P08 または P09 |
| 17 | `pf-cloud-k8s` のベースと overlay 群。最初の横断完成は P05 + P10 |
| 18 | `pf-cloud-o11y`。全アプリの標準。フェーズ 0 で Compose を先に完成 |

## 実装順序

1. `pf-cloud-o11y` の Compose。サンプルアプリで RED ダッシュボードとトレース — **完了**
2. 計装ガイドライン（ログ JSON キー名、`http.route` の正規化、禁止ラベル）— 正本: `portfolio-plan/cloud-platform/docs/` — **完了**
3. **連携デモ設計の文書化**（`portfolio-plan/integration-demo.md`、本ファイル overlay 章）— **完了**
4. `pf-cloud-k8s` 骨組み + foundation overlay（P01 + P03 + o11y 最小）— **完了**
5. overlay 群を A-F に分割し、まず `portfolio-integration-c-scheduling-talent` を完成 — **完了**（A は `portfolio-integration-a-foundation` 別名併存）
6. P04 の `deploy/k8s/` と overlay `b-collab`（P01+P02+P03+P04+P11 portal）— **完了**
7. GitHub OIDC と `pf-cloud-aws` モジュール — **完了**（P09 env 配線まで）。`terraform fmt` + `validate`。資格情報があるときだけ `plan` してよい。**`apply` は非目標（本番デプロイしない）**
8. 学習アカウントへ 3-tier を載せる — **非目標。** 残作業にしない。コスト・destroy は README に残す（誤操作時）
9. 障害注入手順（高レイテンシ、5xx、pod kill）を文書化。P12 のシナリオの素材になる — **一部完了**（o11y debug）。pod kill は連携デモの手動

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
- **連携デモ foundation**: IdP ログイン → media アップロード → Grafana に trace（`integration-demo.md`）
- **連携デモ scheduling-talent**: P10 で job 作成 → P05 予約確定 → webhook で `interview` 更新
- kind / Docker Desktop K8s で pod を消しても Deployment が戻ること
- Terraform **validate**（任意で資格情報付き **plan**、秘密マスク）。apply 済み環境はデモに使わない

## 非目標

- サービスメッシュ（Istio）
- マルチリージョン
- 本番級の長期保持と課金最適化のやり込み
