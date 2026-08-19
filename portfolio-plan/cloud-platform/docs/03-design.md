# P02 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | o11y、k8s overlay、AWS モジュール（apply しない） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

要件の「何を守るか」に対し、リポジトリとモジュールで「どう守るか」。スタック選定の短文は `DESIGN.md`。

## 1. 全体構成

```
pf-cloud-o11y/     Collector, Prometheus, Loki, Tempo, Grafana, demo-api
pf-cloud-k8s/      kustomize 束ね役。製品 Deployment 本文は持たない
pf-cloud-aws/      Terraform モジュール + P09 env。実行は非目標
```

ライフサイクルが違うのでポリレポ。観測はどの実行基盤でも同じ計装にする。

## 2. 連携 overlay

| 置き場所 | 内容 |
| --- | --- |
| `pf-cloud-k8s/deploy/base/` | Ingress クラス、platform Namespace 雛形 |
| `pf-cloud-k8s/deploy/platform/` | Postgres / Redis / Garage / o11y |
| 各 `pf-*/deploy/k8s/` | その製品の Deployment / Service |
| `overlays/portfolio-integration-*` | 参照の束。docker-desktop* は `IfNotPresent` patch |

Postgres は platform の 1 Pod、DB 名で分離。Secret 平文を Git に置かない。

## 3. 計装（旧 `pf-cloud-o11y/docs/instrumentation.md`）

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

## 4. AWS 3-tier モジュール（説明用）

最初の配線先は P09 attendance。Internet → ALB（public）→ ECS Fargate（private）→ RDS（private）。SSH なし。コンテナへは ECS Exec。NAT Gateway は 1。サブネットは 2 AZ でも egress は NAT 1。

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

## 6. 未実装（計画と明示）

- overlay D への P07 / P11 / P12 / P13
- kind overlay（CI）
- platform 常駐とアプリ overlay の kustomize 分割（切替のたびに platform を消さない）
- P02 → P12 の署名付きアラート webhook の固定 JSON（例は DESIGN。実装は P12 が受信側スライス済み、送信側は未配線）
- AWS 上での P09 実デプロイ
