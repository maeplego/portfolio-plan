# ポートフォリオの確認手順（採用担当者向け）

| 項目 | 値 |
| --- | --- |
| 対象 | 採用担当者・レビュア |
| 既定の経路 | ブラウザ、必要なら Docker Compose。**Kubernetes は任意** |
| 最終更新 | 2026-08-21 |

GitHub でコードを見て、必要なら Docker Compose を 1 パック起動してください。Kubernetes は必須ではありません。

公開リポジトリは **デモ・学習・社内評価用** です。保証はなく、本番・商用利用は別契約です（[licensing.md](./licensing.md) / 各 `LICENSE`）。

## 0. ブラウザだけ（約 5 分）

GitHub の `pf-*` と、このメタリポジトリを見る。

1. **P01 identity** — authorize、consent、PKCE、token、JWKS（`pf-identity`）
2. **P04 workspace または P06 commerce** — 画面のある本線（`pf-workspace` または `pf-commerce`）
3. **深さ 1 本** — P02 観測、P11 開発者ポータル、P12 インシデントのいずれか

構成と「やらなかったこと」は `portfolio-plan/00-overview.md` と各 `portfolio-plan/<project>/DESIGN.md`。

常時公開の IdP は無い。AWS への `terraform apply` は **対象外**。

## 1. Compose パック 1 つ（Docker Desktop。Kubernetes はオフでよい）

作業ディレクトリは `pf-cloud-k8s`。兄弟の製品リポジトリが clone 済みであること。

```powershell
cd pf-cloud-k8s
$env:GHCR_OWNER = "maeplego"   # 各 pf-* が公開 GHCR イメージを出したあと
.\scripts\review-up.ps1 -Pack p01-p03   # または p04 / p06
```

GHCR を使うとき（`GHCR_OWNER` あり）は `docker compose pull` のあと `up -d --no-build`。

開発マシンでは **`-UseLocalImages` が各製品の `deploy/compose.yaml` からビルドする**（初回は遅い。2 回目以降はキャッシュ）。手元で `pf-*:latest` を先に tag する必要は無い。

| パック | 見えるもの | URL |
| --- | --- | --- |
| `p01-p03` | IdP、admin、sample RP、media（OIDC + org テナント） | http://localhost:8080 · http://localhost:3002 · http://localhost:3001 · http://localhost:3004 |
| `p04` | IdP + ワークスペース（カンバン / Wiki / チャット、org テナント） | http://localhost:3006 |
| `p06` | IdP + ストアフロント、在庫 1 デモ、ops（org テナント） | http://localhost:3009 · `/demo` · http://localhost:3010 · http://localhost:8099/health · http://localhost:8110/health |

GHCR が無いとき:

```powershell
.\scripts\review-up.ps1 -Pack p04 -UseLocalImages
.\scripts\review-up.ps1 -Pack p06 -UseLocalImages
```

初回はイメージをビルドする。以降はキャッシュ。`p06` は payment、notify、BFF、ops-web も起動する。

## 3 点デモ（Compose 起動後）

**A. 認証（パック `p01-p03`）**

1. http://localhost:3001（sample RP）を開き、ログインする
2. デモユーザーは IdP の Compose がシードする（`pf-identity` の README）。本番アカウントではない
3. 管理 UI は http://localhost:3002

**B. 本線（どちらか一方）**

- P04: http://localhost:3006 — ワークスペースを作る（Compose は開発ヘッダ認証）
- P06: http://localhost:3009/demo — 在庫 1 の同時購入（片方だけ成功）

**C. 深さ（任意。まだ K8s ではない）**

- P02: `pf-cloud-o11y/deploy` の Compose と Grafana（そちらの README）

## 既知の制限

- Compose パックの media / workspace / commerce は **開発認証**。アプリ横断の本格 OIDC は **任意** の K8s foundation overlay
- GHCR の tag は、各 `pf-*` が `pf-cloud-k8s/docs/example-github-push-ghcr.yml` の例ワークフローを動かしたあとに存在する。それまでは `-UseLocalImages`（ローカルビルド）
- Docker Desktop Kubernetes 12 GB、約 28 イメージの import、overlay 切替は **採用担当者の既定経路ではない**
- 実カード番号、実家計、本番 AWS は使わない

テストと GitHub Actions の層（何が CI で、何が手元か）は [`portfolio-plan/ci.md`](ci.md) です。

## 片付け

終わったら `pf-cloud-k8s` で `.\scripts\cleanup.ps1`（既定は K8s overlay だけ止める）。Compose のボリュームは `.\scripts\review-down.ps1 -Pack p04` または `-Pack p06`。まとめて消すときは `.\scripts\cleanup.ps1 -Level full`（`-Yes` が無いと確認する）。

## GitHub ピン（3 点）

プロフィールに載せるのは次だけ。15 個全部はピンしない。

1. このメタリポジトリ（本ファイルと `00-overview.md`）
2. **P01** `pf-identity`、または本線の **P04** `pf-workspace` / **P06** `pf-commerce` のどちらか
3. 深さ 1 本: `pf-cloud-o11y`（観測）、`pf-developer-portal`（oasdiff）、`pf-reliability`（訓練採点）、`pf-recommend`（fail-closed）のいずれか

## 口頭での説明例（約 5 分）

15 個全部は扱いません。

- **認証（pf-identity）**: PKCE、redirect URI の完全一致、refresh の回転（再利用で family 無効化）
- **本線どちらか**: ワークスペース（pf-workspace）ならワークスペース作成。EC（pf-commerce）なら `/demo` で在庫 1 の同時購入（片方 201、片方 409）
- **深さ 1 つ**: トレースが Grafana に出ること、OpenAPI の破壊的変更で CI が落ちること、訓練で scale が減点になること、推薦失敗時に人気へ戻ること、のいずれか

やらなかったこと（Terraform apply、習慣アプリの K8s、全 Pxx 同時起動）はブログ記事 `why-fifteen-products` と `00-overview.md` に書いてある。

