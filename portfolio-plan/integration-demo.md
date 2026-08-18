# ポートフォリオ連携デモ（Integration Demo）

採用担当者・レビュアが **複数 Pxx の横断動作** を確認するための手順の正本。製品コードは兄弟 `pf-*` と `pf-cloud-k8s` に置く。

## 2 つのローカルデモモード

| モード | 目的 | 起動方法 | 必須？ |
| --- | --- | --- | --- |
| **単体デモ** | 各 Pxx の機能をその製品だけで確認 | 各 `pf-*/deploy/compose.yaml` | **はい**（デフォルト） |
| **連携デモ** | IdP → アプリ → 観測 などエコシステム連携 | Docker Desktop Kubernetes + `pf-cloud-k8s` overlay | 任意（深掘り用） |

- **全 Pxx を同時フル起動するのは非目標**（Pod 数・メモリの都合）。
- 単体デモでは dev 認証・stub で **他 Pxx なしでも完結** する（`00-overview.md` の単独起動規約）。
- 連携デモでは **本物の OIDC・共有 Postgres・Ingress** で横断フローを見せる。

## 連携デモの初版スコープ（portfolio-integration）

| 含める | リポジトリ | 役割 |
| --- | --- | --- |
| P01 IdP + admin | `pf-identity` | OIDC 発行。media web が PKCE ログイン |
| P02 観測（最小） | `pf-cloud-o11y` | OTLP Collector + Grafana（トレース確認） |
| P03 media | `pf-media` | api / web / processor。Garage 互換オブジェクト |

**含めない（初版）**: P04 以降、P06 フル、AWS S3→SQS→Lambda。追加は overlay に Namespace を足す形で拡張する。

## 前提（レビュア環境）

- Windows 10/11 または macOS
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（Compose 単体デモでも使用）
- **連携デモ追加**: Docker Desktop → Settings → Kubernetes → **Enable Kubernetes**
- Docker Desktop に割り当て RAM **10 GB 以上** 推奨（8 GB 最低、他アプリを閉じる）
- `kubectl`（Docker Desktop 同梱）
- 兄弟リポジトリを clone 済み（後述「リポジトリ配置」）

AWS アカウント・LocalStack・kind の別途インストールは **不要**（CI 用 kind overlay は将来）。

## リポジトリ配置

親ディレクトリ（例: `portfolio_20260817/`）に **兄弟 Git リポジトリ** を並べる。

```
portfolio_20260817/
├── project/              # メタ（本ファイル、DESIGN、指示）
├── pf-identity/          # P01
├── pf-cloud-o11y/        # P02 観測
├── pf-cloud-k8s/         # P02 連携デモの束ね役
└── pf-media/             # P03
```

Cursor では `project/portfolio.code-workspace` を開く。`pf-cloud-k8s` 追加後は `portfolio-plan/product-repos.json` を更新し `scripts/sync-workspace.ps1` を実行。

## 単体デモ（各 Pxx）

各製品 README に従う。例:

```powershell
cd pf-media/deploy
copy .env.example .env
docker compose -f compose.yaml --env-file .env up --build
```

| 製品 | 代表 URL | 認証 |
| --- | --- | --- |
| P01 | http://localhost:8080 (IdP), :3002 (admin) | Compose 手順参照 |
| P02 | Grafana 等（`pf-cloud-o11y/deploy/README.md`） | — |
| P03 | http://localhost:3004 | 既定 dev（`?user=`）または OIDC  env 設定時 |

## 連携デモ（Kubernetes）

> **ステータス**: `pf-cloud-k8s` に骨組みあり。CI/ローカル smoke は `scripts/smoke.ps1`（kustomize + client dry-run）。実 Pod 起動・OIDC は Docker Desktop / kind 上で別途確認。

### 1. Kubernetes を有効化

Docker Desktop → Settings → Kubernetes → Enable → 待機（緑になるまで）。

```powershell
kubectl config current-context
# docker-desktop であること
kubectl get nodes
```

### 2. イメージをビルド

```powershell
cd pf-cloud-k8s
.\scripts\build-images.ps1
```

### 3. 連携 overlay を apply

```powershell
cd pf-cloud-k8s
.\scripts\smoke.ps1    # manifest 検証（コミット前 gate）
.\scripts\up.ps1
```

### 4. 起動待ち

```powershell
kubectl get pods -A
kubectl wait --for=condition=ready pod -l app=platform-postgres -n platform --timeout=300s
```

### 5. URL 一覧（初版・予定）

Ingress は `localhost` ベース。実装時に `pf-cloud-k8s/docs/urls.md` と同期する。

| 用途 | URL（予定） | 備考 |
| --- | --- | --- |
| P01 IdP | http://localhost/idp/ または :8080 NodePort | issuer URL は overlay で固定 |
| P01 admin | http://localhost/admin/ | |
| P03 media web | http://localhost/media/ | OIDC 必須 |
| P03 media API | クラスタ内 / Ingress 経由 | web から |
| Grafana | http://localhost/grafana/ | 匿名 or 固定 admin（学習用） |

### 6. デモシナリオ（5 分）

1. media web を開く → IdP ログインへリダイレクト
2. デモユーザーでログイン → マイドライブ表示
3. 画像をアップロード → 数秒後サムネ表示
4. Grafana を開く → media-api の trace が Collector 経由で見える
5. （任意）別ブラウザ / シークレットでユーザー B → A のファイルが見えない

### 7. 片付け

```powershell
cd pf-cloud-k8s
.\scripts\down.ps1
```

Docker Desktop Kubernetes を無効化してもよい。単体 Compose デモには影響しない。

## 論理アーキテクチャ

```
Docker Desktop Kubernetes
┌──────────────────────────────────────────────────────────┐
│ Ingress (nginx)                                           │
│   /idp  /admin  /media  /grafana  …                       │
├──────────────────────────────────────────────────────────┤
│ namespace: platform                                       │
│   postgres (DB: identity, media)                          │
│   redis, garage (S3 互換), otel-collector                 │
├──────────────────────────────────────────────────────────┤
│ namespace: p01        │ namespace: p03                     │
│   idp, admin          │   api, web, processor              │
└──────────────────────────────────────────────────────────┘
```

- **Postgres は 1 インスタンス・DB 複数** で Pod 数を抑える。
- **Redis / Garage** も platform で共有（P03 processor キュー・オブジェクト）。
- 各アプリの Deployment 本文は **各 `pf-*/deploy/k8s/`** に置き、`pf-cloud-k8s` が kustomize で参照する。

## Compose 単体との関係

| 項目 | 単体 Compose | 連携 K8s |
| --- | --- | --- |
| 認証 | dev / stub 可 | P01 OIDC 必須 |
| Postgres | 製品ごと 1 コンテナ | platform で DB 共有 |
| イメージ | 各 compose build | **同じ Dockerfile** を再利用 |
| 観測 | 各 compose 内 or なし | platform Collector に統一 |

本番 AWS（S3→SQS→Lambda）は **どちらのローカルモードとも別章**。P03 ローカルは Redis + processor のまま。

## トラブルシュート

| 症状 | 確認 |
| --- | --- |
| Pod Pending | `kubectl describe pod`。Docker Desktop の CPU/RAM 上限 |
| ImagePullBackOff | イメージをローカル build したか。`imagePullPolicy: IfNotPresent` |
| Ingress 404 | Ingress クラス・path 規則。`kubectl describe ingress` |
| OIDC redirect 不一致 | client redirect URI が overlay の media URL と一致 |
| Grafana に trace が無い | `OTEL_EXPORTER_OTLP_ENDPOINT` が platform collector を指すか |

## 実装ロードマップ（P02）

1. 本ファイル + `cloud-platform/DESIGN.md` 追記（**完了**）
2. `pf-cloud-k8s` リポジトリ作成、`product-repos.json` 登録（**完了**）
3. overlay 骨組み（namespace / ingress / placeholder）（**完了**）
4. platform（postgres + redis + garage）（**完了**）
5. P01 + P03 manifest 接続、OIDC クライアント seed（**骨組み完了** — 実機検証待ち）
6. P02 o11y 最小を platform に載せる（**完了**）
7. `build-images.ps1` / `up.ps1` / `smoke.ps1`（**完了**）、クラスタ実機 E2E（任意）

## 関連ドキュメント

- `portfolio-plan/00-overview.md` — エコシステム全体・単独起動規約
- `portfolio-plan/cloud-platform/DESIGN.md` — P02 技術正本・overlay 責務
- `portfolio-plan/instructions.md` — 各 pf-* の `deploy/k8s/` 規約
