# P02 cloud-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-cloud-o11y`、`../pf-cloud-k8s`、`../pf-cloud-aws` |
| 設計 | [cloud-platform/DESIGN.md](../cloud-platform/DESIGN.md) |
| 連携デモ正本 | [07-integration-demo.md](../07-integration-demo.md) |

---

## 1. 識別

| リポ | 元アイデア | 役割 |
| --- | --- | --- |
| **pf-cloud-o11y** | 18 | OpenTelemetry Collector、Prometheus、Loki、Tempo、Grafana、計装見本 `demo-api` |
| **pf-cloud-k8s** | 17 | 連携デモの **kustomize 束ね役**＋Compose レビューパック入口。Deployment 本文は各 `pf-*/deploy/k8s/` |
| **pf-cloud-aws** | 16 | Terraform 3-tier モジュール + P09 向け env。**validate まで。apply 非目標** |

---

## 2. 目的・スコープ

アプリごとに VPC／Grafana をコピーしない。「箱」と「見る手段」の標準化。

| モード | 正 | 用途 |
| --- | --- | --- |
| 単体 Compose | 各 `pf-*` + `review-up.ps1`／`demo.ps1` | 採用既定（L1） |
| 連携 K8s | Docker Desktop + overlay A–F | 横断（L2・任意） |
| AWS | モジュール説明 + `fmt`／`validate` | 設計デモ（apply しない） |

---

## 3. pf-cloud-o11y（実装済み）

### Compose スタック

Collector（OTLP 4317/4318）、Prometheus（9090）、Loki（3100）、Tempo（3200）、Promtail、Grafana（**ホスト 3020**）、demo-api（**8088**）。

パイプライン: App → Collector → Tempo／Prometheus exporter（8889）。

### demo-api

`GET /health` `/ready` `/work/{id}`。`ENABLE_DEBUG=true` 時のみ slow／fail 注入。OTel HTTP + JSON ログ。

### アラート

`deploy/prometheus/alerts.yml`: **`OtelCollectorDown`** のみ。Alertmanager／P12 webhook 配線なし。5xx 比率アラートは未完成に近い。

### K8s 最小

Collector + Tempo + Grafana（namespace `platform`）。Prometheus／Loki フルは Compose 側。単体 apply 禁止 → `pf-cloud-k8s` 経由。

---

## 4. pf-cloud-k8s（実装済み）

### Overlay A–F（実装＝kustomization）

| Overlay | 含む（コード上） |
| --- | --- |
| **A** foundation | P01, P03, o11y |
| **B** collab | P01–P04, P11 portal, o11y |
| **C** scheduling-talent | P01, P05, P07, P10, o11y |
| **D** commerce | P01, P03, P06, P07, **P11 portal, P12**, o11y |
| **E** content | P01, P03, P08, **P11 portal**, o11y |
| **F** ops | P01, P09, **P16**, P12, P14, P15 API, o11y |

共有 platform: Postgres、Redis、Garage、Collector、Grafana、Ingress（`*.localhost`）。

### Staging

**B / C / D / F** に `*-staging`（DEV_AUTH オフ）。A／E の staging は無し。Smoke: `cluster-smoke-*-staging.ps1`。

### Scripts

`review-up.ps1`／`demo.ps1`／`cleanup.ps1`、`up-*`／`cluster-smoke-*`、`build-images.ps1`／`load-images.ps1`、`oidc-smoke.ps1`、`expose-ingress.ps1` 等。索引: `pf-cloud-k8s/scripts/README.md`。

---

## 5. pf-cloud-aws（実装済み）

| モジュール | 内容 |
| --- | --- |
| vpc / alb / ecs / rds | 2 AZ、ALB、Fargate、Postgres |
| github_oidc | GHA → assume role |
| billing | EstimatedCharges アラーム（しきい値例 20 USD） |

Env: `envs/dev-p09-attendance`（P09 配線）。検証:

```text
terraform fmt -recursive
terraform -chdir=envs/dev-p09-attendance init -backend=false
terraform -chdir=envs/dev-p09-attendance validate
```

**`terraform apply` は非目標。**

---

## 6. デモ起動

```powershell
# 採用既定
cd pf-cloud-k8s
.\scripts\review-up.ps1 -Pack p01-p03 -UseLocalImages

# 観測単体
cd pf-cloud-o11y\deploy
docker compose -f compose.yaml --env-file .env up --build
# Grafana http://localhost:3020

# 連携 K8s（例）
.\scripts\cluster-smoke.ps1
.\scripts\expose-ingress.ps1
```

---

## 7. 他 Pxx との関係

- 全アプリ: `/health` `/ready`、`OTEL_EXPORTER_OTLP_ENDPOINT`、JSON ログ契約。
- P01 はほぼ全 overlay の OIDC 正本。
- P09 は AWS Terraform の配線先。P16 は f-ops。
- P13／P15 Expo／P11 ツール群は K8s 非搭載。

---

## 8. 非目標

`terraform apply`、全 overlay 同時常駐、Istio、マルチリージョン、Alertmanager→P12 自動修復、standalone kind をレビュア正とする。

---

## 9. テスト・検証

| 層 | 内容 |
| --- | --- |
| o11y | `go test`（demo-api）、kustomize、compose config |
| k8s | `test-scripts.ps1 -ParseOnly`、dry-run。A–F 実 kustomize は兄弟依存で GHA 制限あり |
| aws | fmt + validate + Trivy |
| 実機 | cluster-smoke／staging／OIDC smoke（Desktop 必須） |

---

## 10. ギャップ／注意点

| # | 内容 |
| --- | --- |
| 1 | ~~`overlay-matrix.md` 等と実装の D／E／F 記述ずれ~~ → **対応済** |
| 2 | ~~観測アラートが Collector down 1 本のみ~~ → **対応済**（5xx／p95 追加。Alertmanager 本番配線は C） |
| 3 | K8s o11y ≠ Compose フルスタック | 対象外(C) |
| 4 | overlay Secret 平文は学習用 | |
| 5 | イメージ load 必須（Desktop はホストイメージを自動共有しない） | |
| 6 | アイデア 16 の apply／HTTPS 等は意図的に縮小 | 対象外(C) |

---

## 11. 根拠パス

- `portfolio-plan/cloud-platform/DESIGN.md`、`docs/*`、`07-integration-demo.md`
- `pf-cloud-o11y/deploy/*`、`apps/demo-api`
- `pf-cloud-k8s/deploy/overlays/**`、`scripts/README.md`、`docs/overlay-matrix.md`
- `pf-cloud-aws/modules/**`、`envs/dev-p09-attendance`、`scripts/validate.ps1`
