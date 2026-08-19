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

## 連携デモの overlay 群

12 GB の Docker Desktop Kubernetes を前提に、全 Pxx を一度は使うための **用途別 overlay 群** に分ける。

| Overlay | 含める | 主目的 |
| --- | --- | --- |
| `portfolio-integration-a-foundation` | P01, P02, P03 | OIDC + media + o11y の最小 smoke |
| `portfolio-integration-b-collab` | P01, P02, P03, P04（P11 は後続） | workspace の連携（P04 サブセット） |
| `portfolio-integration-c-scheduling-talent` | P01, P02, P05, P07, P10 | 採用ドメイン |
| `portfolio-integration-d-commerce` | P01, P02, P03, P06（P07 / P11 / P12 / P13 は後続） | commerce 本線（P06 サブセット） |
| `portfolio-integration-e-content` | P01, P02, P03, P08（P11 は後続） | content / media |
| `portfolio-integration-f-ops` | P01, P02, P09, P12, P14, P15 API | 業務 / 個人向け軽量群 |

現時点の実装済み K8s overlay:

- `portfolio-integration-a-foundation` + `docker-desktop-a-foundation`（`portfolio-integration` の別名）
- `portfolio-integration` + `docker-desktop`（上記と同じ。後方互換）
- `portfolio-integration-c-scheduling-talent` + `docker-desktop-c-scheduling-talent`
- `portfolio-integration-b-collab` + `docker-desktop-b-collab`（P04 サブセット。P11 portal は未搭載）
- `portfolio-integration-e-content` + `docker-desktop-e-content`（P08。P11 portal は未搭載）
- `portfolio-integration-d-commerce` + `docker-desktop-d-commerce`（P06 サブセット。P07/P11/P12/P13 は未搭載）
- `portfolio-integration-f-ops` + `docker-desktop-f-ops`（P09 / P12 / P14 / P15 API。Expo は非搭載）

## overlay の切り替え（12 GB 制約）

用途別 overlay は **同時に全部載せない**。切り替え時は前の overlay を down してから apply する。

| 切り替え | 手順 |
| --- | --- |
| foundation → scheduling-talent | `.\scripts\down.ps1`（または `down-a-foundation.ps1`）→ `.\scripts\cluster-smoke-c-scheduling-talent.ps1` |
| scheduling-talent → foundation | `.\scripts\down-c-scheduling-talent.ps1` → `.\scripts\cluster-smoke.ps1` |
| いずれか → collab（P04） | `.\scripts\down-c-scheduling-talent.ps1` と `.\scripts\down-a-foundation.ps1` → `.\scripts\cluster-smoke-b-collab.ps1`（`up-b-collab.ps1` が他 overlay を down する） |
| いずれか → content（P08） | `.\scripts\cluster-smoke-e-content.ps1`（`up-e-content.ps1` が他 overlay を down する） |
| いずれか → commerce（P06） | `.\scripts\cluster-smoke-d-commerce.ps1`（`up-d-commerce.ps1` が他 overlay を down する。F が載っているときは落とす） |
| いずれか → ops（P09/P12/P14/P15 API） | `.\scripts\cluster-smoke-f-ops.ps1`（`up-f-ops.ps1` が他 overlay を down する） |

platform（Postgres / Redis / Garage / o11y）は両 overlay で共有する。`ensure-platform-databases.ps1` は apply 時に DB/user を足す。

## 前提（レビュア環境）

- Windows 10/11 または macOS
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（Compose 単体デモでも使用）
- **連携デモ追加**: Docker Desktop → Settings → Kubernetes → **Enable Kubernetes**
- Kubernetes バージョンは **1.34.x** を推奨。**1.36.x は kubeadm init が `wait-control-plane` で失敗することがある**（このマシンでは 1.34.8 で起動確認）
- Docker Desktop に割り当て RAM **10 GB 以上** 推奨（8 GB 最低、他アプリを閉じる）。**2 GB 程度では kubeadm init がタイムアウトする**
- `.wslconfig` の `memory=` 変更は Docker Desktop 再起動だけでは効かない。`wsl --shutdown` のあと Desktop を起動する
- `kubectl`（Docker Desktop 同梱）
- 兄弟リポジトリを clone 済み（後述「リポジトリ配置」）

AWS アカウント・LocalStack・**standalone kind** の別途インストールは **不要**（CI 用 kind overlay は将来。レビュア手順では使わない）。アイデア 16 の Terraform 3-tier（`pf-cloud-aws`）は **この連携デモの経路ではない**し、**このポートフォリオは AWS へ本番 `apply` しない**（残作業にもしない）。モジュールは面接用。K8s 手順はそのまま使う。人間向け書類の正本: `portfolio-plan/cloud-platform/docs/`。

## リポジトリ配置

親ディレクトリ（例: `portfolio_20260817/`）に **兄弟 Git リポジトリ** を並べる。

```
portfolio_20260817/
├── project/              # メタ（本ファイル、DESIGN、指示）
├── pf-identity/          # P01
├── pf-cloud-o11y/        # P02 観測
├── pf-cloud-k8s/         # P02 連携デモの束ね役
├── pf-cloud-aws/         # P02 Terraform 3-tier（P09。K8s 連携デモとは別）
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

> **ステータス**: foundation overlay は IdP ログイン → media ホームまで `oidc-smoke.ps1` / `demo-smoke.ps1` が通る。scheduling-talent overlay は Docker Desktop Kubernetes（context `docker-desktop`）上で `cluster-smoke-c-scheduling-talent.ps1` が予約確定 → `interview` まで通り、`http://talent.localhost` と `http://talent-api.localhost/health` を Ingress 確認済み（2026-08-19）。b-collab overlay は P04 サブセット（P01+P02+P03+P04。P11 なし）。e-content は P08（blog + shortener。P11 なし）。d-commerce は P06 サブセット（P01+P02+P03+P06。P07/P11/P12/P13 なし）。f-ops は P09 / P12 / P14 / P15 API（Expo なし）。standalone kind では検証しない。

### 0. kubectl context（必須）

```powershell
kubectl config use-context docker-desktop
kubectl config current-context   # docker-desktop であること
kubectl get nodes
```

`kind-kind` 等の standalone kind context のまま apply しない。`scripts/up.ps1` / `cluster-smoke.ps1` は context 不一致で停止する。

### 1. Kubernetes を有効化

Docker Desktop → Settings → Kubernetes → Enable → 待機（緑になるまで）。

```powershell
kubectl config current-context
# docker-desktop であること
kubectl get nodes
```

### 2. イメージをビルドしてノードへ載せる

Docker Desktop Kubernetes（kind モード）は **ホストの Docker イメージを自動では見ない**。`desktop-control-plane` の containerd へ import する。`build-images.ps1` は foundation に加え P04 / P05 / P08 / P09 / P10 / P12 / P14 / P15 API / P06 イメージも build する。overlay 指定: `-Overlay e-content` / `-Overlay f-ops` / `-Overlay d-commerce`。

```powershell
cd pf-cloud-k8s
.\scripts\build-images.ps1
.\scripts\load-images.ps1
```

### 3. 連携 overlay を apply

#### foundation（P01 + P03 + o11y）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke.ps1
.\scripts\expose-ingress.ps1
.\scripts\oidc-smoke.ps1
.\scripts\demo-smoke.ps1
```

#### scheduling-talent（P05 + P10）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-c-scheduling-talent.ps1
.\scripts\expose-ingress.ps1
```

#### collab（P04 サブセット。P11 portal なし）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-b-collab.ps1
.\scripts\expose-ingress.ps1
```

#### content（P08。P11 portal なし）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-e-content.ps1
.\scripts\expose-ingress.ps1
```

#### commerce（P06 サブセット。P07 / P11 / P12 / P13 なし）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-d-commerce.ps1
.\scripts\expose-ingress.ps1
```

#### ops（P09 / P12 / P14 / P15 API。Expo なし）

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-f-ops.ps1
.\scripts\expose-ingress.ps1
```

### 4. 起動待ち

```powershell
kubectl get pods -A
kubectl wait --for=condition=ready pod -l app=platform-postgres -n platform --timeout=300s
```

### 5. URL 一覧

ホスト名ベース（`pf-cloud-k8s/docs/urls.md`）。Docker Desktop の kind ノードは 80 を公開しないため `expose-ingress.ps1` が `localhost:80` を NodePort へプロキシする。

| 用途 | URL | 備考 |
| --- | --- | --- |
| P01 IdP | http://idp.localhost | issuer |
| P01 admin | http://admin.localhost | |
| P03 media web | http://media.localhost | OIDC 必須。未ログインは `/login` |
| P04 workspace web | http://workspace.localhost | OIDC 必須。未ログインは `/login` |
| P04 workspace API | http://workspace-api.localhost | REST + チャット WS。overlay smoke は `X-Dev-User-Sub` |
| P04 workspace collab | http://workspace-collab.localhost | Yjs / Hocuspocus。チャット WS とは別ホスト |
| P05 calendar web | http://calendar.localhost | 公開予約 UI |
| P05 calendar API | http://calendar-api.localhost | public / internal API |
| P10 talent web | http://talent.localhost | OIDC 必須。ログイン後の acting user は `?user=candidate-1` |
| P10 talent API | http://talent-api.localhost | talent API。overlay では Bearer または `X-Dev-User-Sub`（`TALENT_DEV_AUTH=true`、cluster-smoke 用） |
| P08 blog | http://blog.localhost | overlay E。管理は `CONTENT_DEV_AUTH` |
| P08 shortener | http://shortener.localhost | overlay E。`SHORTENER_DEV_AUTH` + `X-Dev-User-Sub` |
| P06 commerce | http://commerce.localhost | overlay D。API は `commerce-api.localhost` |
| P09 attendance | http://attendance.localhost | overlay F。API は `attendance-api.localhost` |
| P12 reliability | http://reliability.localhost | overlay F。メモリストア |
| P14 finance | http://finance.localhost | overlay F。API は `finance-api.localhost` |
| P15 habit API | http://habit-api.localhost | overlay F。Expo はクラスタに載せない |
| Grafana | http://grafana.localhost | 学習用 admin/admin。Tempo を既定 datasource |
| Garage S3 | http://garage.localhost | 署名付き GET/PUT（ブラウザと media-web） |

### 6. デモシナリオ（5 分）

#### foundation

学習用デモユーザー（本番アカウントではない）。メール `demo@example.test`。パスワードは overlay `IDENTITY_SEED_DEMO_PASSWORD`（`pf-cloud-k8s` の `idp-env.yaml`）。

1. [http://media.localhost](http://media.localhost) を開く → IdP ログインへリダイレクト
2. 上記デモユーザーでログイン → 同意で許可 → マイドライブ（容量表示）
3. 画像をアップロード → 数秒後サムネ表示（オブジェクト URL は `garage.localhost`）
4. [http://grafana.localhost](http://grafana.localhost)（学習用 admin/admin）→ ホーム **Media API traces** → Tempo Explore。`{resource.service.name="media-api"}`。`/health` は出さない
5. （任意）別ブラウザ / シークレットで別ユーザーを登録すると、A のファイルは見えない

#### scheduling-talent

`cluster-smoke-c-scheduling-talent.ps1` は次を自動で確認する。

1. P10 で job 作成
2. P10 から P05 internal API で面接 event type を provision
3. P10 で application 作成 + `document_passed`
4. P10 で interview slots 取得
5. P05 public booking API で予約
6. `calendar.booking.confirmed` により P10 の応募が `interview` へ更新

目視確認するときの URL:

- [http://calendar.localhost](http://calendar.localhost)
- [http://talent.localhost/?user=candidate-1](http://talent.localhost/?user=candidate-1)（web）
- [http://talent-api.localhost/health](http://talent-api.localhost/health)

#### collab（P04）

`cluster-smoke-b-collab.ps1` は api / collab / web の `/health`、API でのワークスペース作成、Ingress の `workspace.localhost` → OIDC を確認する。学習用デモユーザーは foundation と同じ（メール `demo@example.test`）。

目視確認するときの URL:

- [http://workspace.localhost](http://workspace.localhost)（OIDC）
- [http://workspace-api.localhost/health](http://workspace-api.localhost/health)
- [http://workspace-collab.localhost/health](http://workspace-collab.localhost/health)
- [http://media.localhost](http://media.localhost)

永続化は platform Postgres の `workspace` DB。Y.Doc は collab メモリ。

#### content（P08）

`cluster-smoke-e-content.ps1` は blog / shortener の health、短縮作成、302、Ingress を確認する。管理は開発認証。学習用デモ記事は架空の Harbor Press。

目視確認するときの URL:

- [http://blog.localhost](http://blog.localhost)
- [http://blog.localhost/demo](http://blog.localhost/demo)
- [http://shortener.localhost/health](http://shortener.localhost/health)
- [http://media.localhost](http://media.localhost)（OIDC。foundation と同じ）

#### commerce（P06）

`cluster-smoke-d-commerce.ps1` は gateway health、カート、在庫 1 の同時 checkout（201 と 409 `inventory_shortage`）、Ingress を確認する。管理は開発認証。決済はモック（カードなし）。学習用シードは `MUG-1` / `TEE-1` / `STK-1`。

目視確認するときの URL:

- [http://commerce.localhost](http://commerce.localhost)
- [http://commerce.localhost/demo](http://commerce.localhost/demo)
- [http://commerce-api.localhost/health](http://commerce-api.localhost/health)
- [http://media.localhost](http://media.localhost)（OIDC。foundation と同じ）

#### ops（P09 / P12 / P14 / P15 API）

`cluster-smoke-f-ops.ps1` は attendance 打刻、reliability インシデント、finance 月次、habit シード一覧、各 API Ingress `/health` を確認する。Expo / habit-mobile はホスト側。

目視確認するときの URL:

- [http://attendance.localhost](http://attendance.localhost)（シード `aoki.haru`）
- [http://reliability.localhost](http://reliability.localhost)
- [http://finance.localhost](http://finance.localhost)（シード `demo`）
- [http://habit-api.localhost/health](http://habit-api.localhost/health)

### 7. 片付け

```powershell
cd pf-cloud-k8s
.\scripts\down.ps1
.\scripts\down-c-scheduling-talent.ps1
.\scripts\down-b-collab.ps1
.\scripts\down-e-content.ps1
.\scripts\down-d-commerce.ps1
.\scripts\down-f-ops.ps1
```

Docker Desktop Kubernetes を無効化してもよい。単体 Compose デモには影響しない。

## 論理アーキテクチャ

```
Docker Desktop Kubernetes
┌──────────────────────────────────────────────────────────┐
│ Ingress (nginx)  idp / media / workspace / calendar / talent / blog / shortener /
│                  commerce / commerce-api / attendance / reliability / finance / habit-api / grafana / garage.localhost
├──────────────────────────────────────────────────────────┤
│ namespace: platform                                       │
│   postgres (DB: identity, media, calendar, talent, workspace, content, commerce_*, ...)   │
│   redis, garage (S3 互換), otel-collector                 │
├──────────────────────────────────────────────────────────┤
│ namespace: p01        │ namespace: p03                     │
│   idp, admin          │   api, web, processor              │
│ namespace: p04        │ namespace: p05                     │
│   api, collab, web    │   api, web, worker                 │
│ namespace: p06        │ namespace: p08                     │
│   catalog, inventory, │   blog, shortener                  │
│   order, api, web     │                                    │
│ namespace: p09        │ namespace: p10                     │
│   api, web            │   api, web                         │
│ namespace: p12        │ namespace: p14                     │
│   api, web（メモリ）   │   api, web                         │
│ namespace: p15        │                                    │
│   api のみ（Expo なし）│                                    │
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
| kubeadm init / wait-control-plane timeout | RAM を 10 GB 前後に。`.wslconfig` 変更後は `wsl --shutdown` → Docker Desktop 起動。それでも失敗なら Kubernetes **1.36.x を 1.34.x に下げる** |
| context が kind-kind | standalone `kind delete cluster` → Docker Desktop K8s を有効化 → `use-context docker-desktop` |
| `assert-docker-desktop` で停止 | 上記のとおり Docker Desktop K8s を Ready にしてから再実行 |
| Pod Pending | `kubectl describe pod`。Docker Desktop の CPU/RAM 上限 |
| ImagePullBackOff（pf-* ローカルイメージ） | `.\scripts\load-images.ps1` を実行。`imagePullPolicy: IfNotPresent` でもノードに無いと Hub へ取りに行く |
| Ingress 404 | Ingress クラス・path 規則。`kubectl describe ingress` |
| OIDC redirect 不一致 | client redirect URI が overlay の media / workspace / talent URL と一致 |
| Grafana に trace が無い | `OTEL_EXPORTER_OTLP_ENDPOINT` が platform collector を指すか |
| `password authentication failed for user "calendar"` | 既存 platform Postgres には `.\scripts\ensure-platform-databases.ps1` を実行して DB/user を追加 |
| calendar-web が `Cannot find module '/app/server.js'` | `pf-calendar` web イメージを再 build（monorepo standalone 用 CMD） |
| PowerShell で `*.localhost` が解決できない | `curl.exe` を使う。Windows の .NET DNS は `workspace.localhost` を解決しないことがある |

## 実装ロードマップ（P02）

1. 本ファイル + `cloud-platform/DESIGN.md` 追記（**完了**）
2. `pf-cloud-k8s` リポジトリ作成、`product-repos.json` 登録（**完了**）
3. overlay 骨組み（namespace / ingress / placeholder）（**完了**）
4. platform（postgres + redis + garage）（**完了**）
5. P01 + P03 manifest 接続、OIDC クライアント seed（**完了**）
6. P02 o11y 最小を platform に載せる（**完了**）。media-api は OTLP、Grafana に Tempo
7. foundation smoke (`cluster-smoke.ps1` + `oidc-smoke.ps1` + `demo-smoke.ps1`）
8. scheduling-talent smoke (`cluster-smoke-c-scheduling-talent.ps1`）
9. b-collab smoke（P04 サブセット。`cluster-smoke-b-collab.ps1`）。P11 portal は後続
10. e-content smoke（P08。`cluster-smoke-e-content.ps1`）。P11 portal は後続
11. f-ops smoke（P09 / P12 / P14 / P15 API。`cluster-smoke-f-ops.ps1`）
12. d-commerce smoke（P06 サブセット。`cluster-smoke-d-commerce.ps1`）。P07 / P11 / P12 / P13 は後続

## 単体 Compose 連携デモ: P05 ↔ P10（予約確定 → 面接ステータス）

> **ステータス**: Compose 単体デモで P05 → P10 webhook 経由の `interview` 更新を確認済み。

### 概要

P05 calendar の予約確定イベント `calendar.booking.confirmed` が outbox → worker → webhook → P10 talent-api に届き、応募ステータスが `interview` に更新されるフローを確認する。

### 前提

- Docker Desktop（Compose 対応）
- 兄弟ディレクトリに `pf-calendar` と `pf-talent-api` が clone 済み

### 手順

#### 1. pf-talent-api を起動

```powershell
cd pf-talent-api/deploy
copy .env.example .env
docker compose up -d --build
```

`http://localhost:8090/health` → `{ "ok": true }`

#### 2. pf-calendar を起動（webhook URL を talent-api に向ける）

```powershell
cd pf-calendar/deploy
copy .env.example .env
```

`.env` に以下を追記（talent-api の webhook エンドポイント）:

```
CALENDAR_WEBHOOK_URL=http://host.docker.internal:8090/webhooks/calendar
```

```powershell
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3005 | P05 Web UI |
| http://localhost:8095/health | P05 API |
| http://localhost:8090/health | P10 API |

#### 3. P10 で求人と応募を作成

```powershell
# 求人作成
$job = Invoke-RestMethod -Method POST -Uri http://localhost:8090/v1/jobs `
  -ContentType 'application/json' `
  -Body '{"employerSub":"employer-1","title":"Backend Engineer","status":"published"}'
$job.id

# P05 にイベントタイプをプロビジョン（externalRef = job.id）
# .env に CALENDAR_INTERNAL_TOKEN を設定しておくこと
Invoke-RestMethod -Method POST `
  -Uri "http://localhost:8090/v1/jobs/$($job.id)/provision-interview-event-type"

# 応募作成（calendarExternalRef = job.id で自動紐付け）
$app = Invoke-RestMethod -Method POST `
  -Uri "http://localhost:8090/v1/jobs/$($job.id)/applications" `
  -ContentType 'application/json' `
  -Body '{"candidateSub":"candidate-1","resumeSnapshot":"3 years Go experience"}'
$app.id
```

#### 4. P05 で公開予約

1. `http://localhost:3005/host` でイベントタイプ一覧を確認（provision で作った `interview-30m-*` が存在）
2. `http://localhost:3005/book/<slug>` で予約（ゲスト名・メールを入力）

#### 5. ステータス確認

worker が outbox を拾い webhook を POST する（デフォルト 60 秒ポーリング）。

```powershell
# 応募ステータスが interview に変わったか確認
Invoke-RestMethod -Uri "http://localhost:8090/v1/applications/$($app.id)"
```

期待: `status` が `"interview"`、`interviewBookingId` がセットされている。

#### 6. 片付け

```powershell
cd pf-calendar/deploy; docker compose down -v
cd pf-talent-api/deploy; docker compose down -v
```

## 関連ドキュメント

- `portfolio-plan/00-overview.md` — エコシステム全体・単独起動規約
- `portfolio-plan/cloud-platform/DESIGN.md` — P02 技術正本・overlay 責務
- `portfolio-plan/instructions.md` — 各 pf-* の `deploy/k8s/` 規約
