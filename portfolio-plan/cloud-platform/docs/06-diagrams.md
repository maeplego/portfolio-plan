# P02 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | 実装済みのローカル 2 モード。AWS 図はモジュール説明（未 apply） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 記法 | Mermaid。ユースケースは UML 楕円の代替としてフロー |

詳細な文章は仕様・設計を正とする。図は構造の索引。

## 1. ユースケース

```mermaid
flowchart LR
  subgraph actors [アクター]
    Rev[レビュア]
    App[製品アプリ]
  end
  subgraph uc [P02]
    UC1[Compose で観測を見る]
    UC2[障害を注入して RED を見る]
    UC3[連携 overlay を起動する]
    UC4[モジュールを validate する]
    UC5[AWS に apply する_非目標]
  end
  Rev --> UC1
  Rev --> UC2
  Rev --> UC3
  Rev --> UC4
  App --> UC1
```

## 2. ローカル観測

```mermaid
sequenceDiagram
  participant App as demo-api
  participant Col as Collector
  participant Prom as Prometheus
  participant Tmp as Tempo
  participant G as Grafana
  App->>Col: OTLP
  Prom->>Col: scrape
  G->>Prom: RED
  G->>Tmp: trace
```

## 3. 連携デモ（同時に全部載せない）

```mermaid
flowchart TB
  DD[Docker Desktop Kubernetes]
  DD --> A[overlay A foundation]
  DD --> B[overlay B collab サブセット]
  DD --> C[overlay C scheduling-talent]
  DD --> E[overlay E content]
  DD --> F[overlay F ops]
  DD -.-> D[D 計画]
```

同時に A–F を載せない。

## 4. AWS 3-tier（モジュール。未 apply）

学習用。マルチリージョン・WAF・Blue/Green は非目標。

```mermaid
flowchart LR
  user[Browser]
  alb[ALB public]
  web[ECS Fargate web]
  api[ECS Fargate api]
  rds[(RDS PostgreSQL private)]
  ssm[ECS Exec]
  oidc[GitHub OIDC]
  ecr[ECR]
  user --> alb
  alb -->|/ /static| web
  alb -->|/health /ready /v1| api
  api --> rds
  oidc --> ecr
  ecr --> web
  ecr --> api
  ssm -.-> api
  ssm -.-> web
```

NAT Gateway は 1。プライベートサブネットの egress（ECR pull、SSM）用。この図を apply 済み環境と読まない。
