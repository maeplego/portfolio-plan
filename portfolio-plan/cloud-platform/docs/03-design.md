# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | クラウド基盤（観測 [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) / Kubernetes [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) / Terraform [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

要件の「何を守るか」に対し、リポジトリとモジュールで「どう守るか」。スタック選定の短文は親の `DESIGN.md`。

## 1. 全体構成

```
pf-cloud-o11y/     Collector, Prometheus, Loki, Tempo, Grafana, demo-api
pf-cloud-k8s/      kustomize 束ね役。製品 Deployment 本文は持たない
pf-cloud-aws/      Terraform モジュール + 勤怠向け env。apply しない
```

ライフサイクルが違うのでリポジトリを分ける。観測はどの実行基盤でも同じ計装にする。

## 2. 連携 overlay

| 置き場所 | 内容 |
| --- | --- |
| `pf-cloud-k8s/deploy/base/` | Ingress クラス、platform Namespace 雛形 |
| `pf-cloud-k8s/deploy/platform/` | Postgres / Redis / Garage / o11y |
| 各 `pf-*/deploy/k8s/` | その製品の Deployment / Service |
| `overlays/portfolio-integration-*` | 参照の束。`docker-desktop*` は `IfNotPresent` patch |

Postgres は platform の 1 Pod、DB 名で分離。Secret 平文を Git に置かない。

overlay D は EC [pf-commerce](https://github.com/maeplego/pf-commerce) フルと推薦 [pf-recommend](https://github.com/maeplego/pf-recommend)、開発者ポータルと信頼性基盤も含む。データ基盤は Compose。

## 3. 計装

アプリはベンダー SDK を Grafana / Jaeger / Loki に直接送らず、Collector 経由。

環境変数:

```env
OTEL_SERVICE_NAME=my-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
```

gRPC は `:4317`。ホストから Docker Collector へは `http://host.docker.internal:4318`（Windows/macOS）。

ログ（stdout 1 行 JSON）:

| キー | 内容 |
| --- | --- |
| `service` | `OTEL_SERVICE_NAME` と同じ |
| `trace_id` / `span_id` | 有効 span があるとき |
| `msg` | イベント名 |
| `http.route` | 正規化済み（`/users/:id`） |

メトリクスは公式 HTTP 計装を使い、カスタムラベルは有限集合。トレースは入口 HTTP で span、DB / 外部 HTTP は子 span。Collector → Tempo。

## 4. AWS 3-tier モジュール（説明用。未 apply）

最初の配線先は勤怠 [pf-attendance](https://github.com/maeplego/pf-attendance)。Internet → ALB（public）→ ECS Fargate（private）→ RDS（private）。SSH なし。コンテナへは ECS Exec。NAT Gateway は 1。サブネットは 2 AZ でも egress は NAT 1。

```
modules/vpc, alb, ecs, rds, github_oidc, billing
bootstrap/remote-state     S3 + DynamoDB lock（設計上の一度。実行義務なし）
envs/dev-p09-attendance    配線の置き場
```

アプリスタックの backend は S3 + lock を想定する。`init -backend=false` は構文チェックでありリモート state の代替ではない。bootstrap だけはバケット自身を作る例外としてローカル state を使う、と README に書いてある。

請求アラームモジュールのしきい値既定は 20 USD（Billing メトリクスは us-east-1）。これは apply した人向けの安全弁であり、apply を勧めるものではない。

## 5. セキュリティ

- Terraform に `0.0.0.0/0:22` を置かない
- RDS `publicly_accessible = false`（モジュール）
- GitHub Actions は OIDC。永久キーを Git に置かない
- Grafana はローカル。クラスタでは Ingress ホスト + 認証

## 6. 未実装

- overlay D への開発者ポータル / 信頼性基盤 / データ基盤
- overlay E への開発者ポータル
- kind overlay（CI）
- platform 常駐とアプリ overlay の kustomize 分割（切替のたびに platform を消さない）
- 観測スタックから信頼性基盤への署名付きアラート webhook（受信側は信頼性基盤、送信側は未配線）
- AWS 上での勤怠の実デプロイ
