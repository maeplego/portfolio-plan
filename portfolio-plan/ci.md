# ポートフォリオの CI とテスト層

| 項目 | 値 |
| --- | --- |
| 対象 | P01–P15 の製品リポジトリと、このメタリポジトリの書類 |
| 最終更新 | 2026-08-20 |
| 実装との関係 | 各 `pf-*` の `.github/workflows/` とテストコマンドが正。未実行の層を「CI で通っている」と書かない |

学習用ポートフォリオのゲートである。SaaS 本番の継続的デプロイではない。

## 既定で GitHub Actions が回すもの

各 `pf-*` の `.github/workflows/ci.yml`（既存があれば延長）:

| 層 | 内容 | 失敗時 |
| --- | --- | --- |
| 単体 / HTTP | そのリポジトリの正本コマンド（`go test ./...`、`npm test`、`python -m pytest`、`mvn test` など） | ジョブ失敗 |
| 依存の脆弱性 | Node: `npm audit --audit-level=high`、または Next/Expo 推移的 HIGH を `scripts/npm-audit-allowlist.json` で理由付き除外。Go: `govulncheck`。Python: `pip-audit` | ジョブ失敗。`npm audit --force` は使わない |
| ファイルシステムスキャン | Trivy `fs`。`HIGH,CRITICAL`。action は `aquasecurity/trivy-action` の **v0.36.0 コミット** にピン（2026-03 の tag 改ざん事故のあと）。デモ用 Kubernetes の `config` スキャンは latest タグ等で常時赤になるため既定ジョブには入れない | 未修正（fix 無し）は `ignore-unfixed`。修正がある HIGH は落とす。Next 15 同梱の postcss / sharp は `.trivyignore`（`npm-audit-allowlist.json` と同じ理由）。`pf-developer-scanner` の `testdata/` は意図した脆弱フィクスチャなので `skip-dirs` |
| 自リポジトリの kustomize | `deploy/k8s/` がある製品は `kubectl kustomize`（組み立てだけ）。ホスト runner に apiserver が無いので `apply` しない | 参照切れ |
| Compose ファイル | `deploy/compose.yaml` があるとき `docker compose config`（起動はしない） | 構文 |

`pf-cloud-k8s` はスクリプト構文と overlay のイメージ集合、`deploy/base` / `platform` / `ingress` の dry-run。A–F overlay の kustomize は **兄弟 `pf-*` の checkout が必要なので GitHub 上のこのリポジトリ単体では回さない。** 手元は `.\scripts\test-scripts.ps1`。

`pf-cloud-aws` は従来どおり `terraform fmt` と `validate`（`backend=false`）。**`apply` は CI に無い。**

`pf-developer-templates` のソースは `{{MODULE}}` のまま置く。CI の checkout 上だけ `example.com/template` に置換してから `go test` する。

## 既定では回さない（ローカルまたは workflow_dispatch）

| 層 | 理由 | 手元の入口 |
| --- | --- | --- |
| Playwright | `npx playwright install --with-deps` が遅く、画面は Compose 前提のものが多い | 下表。P01 の `apps/e2e` はメモリ IdP で完結するので dispatch 可 |
| `docker compose up` | イメージビルドが PR 毎には重い。GitHub-hosted に Docker Desktop Kubernetes は無い | 各 `deploy/compose.yaml` のあと `node scripts/compose-smoke.mjs …`（置いてある製品） |
| クラスタ smoke | overlay 切替と 10 GB 超 RAM | `pf-cloud-k8s/scripts/review-up.ps1` と `cluster-smoke-*.ps1` |
| イメージをレジストリへ push | 秘密と GHCR 権限がこのメタ作業には無い | `pf-cloud-k8s/docs/example-github-push-ghcr.yml` はコピー用の例 |

## Playwright（実装済みの旅程）

CI 既定ジョブではない。`workflow_dispatch` の `e2e.yml` があるリポジトリと、Compose 前提のローカル専用を分ける。

| 製品 | 旅程 | CI | 実行 |
| --- | --- | --- | --- |
| P01 `pf-identity` | sample RP ログイン（既存 `apps/e2e`） | `e2e.yml` は dispatch | `apps/e2e` で `npx playwright test` |
| P05 `pf-calendar` | 公開予約 1 件（メモリ API + Next） | `e2e.yml` は dispatch | `apps/e2e` で `npx playwright test` |
| P14 `pf-finance` | 今月サマリー（メモリ API + PWA） | `e2e.yml` は dispatch | `apps/web` の `npm run test:e2e` |
| P08 `pf-content-blog` | 公開記事 1 本（メモリ store） | `e2e.yml` は dispatch | `npm run test:e2e` |
| P06 `pf-commerce` | `/demo` 見出し | **ローカルのみ**（カタログ〜決済が Compose） | Compose 後 `apps/storefront` の `npm run test:e2e` |

ワークスペース・勤怠 Web・習慣モバイルのフル E2E はこのスライスでは足していない。

## 手元で脆弱性スキャンする

```powershell
# Node（lockfile のあるディレクトリ）
npm audit --audit-level=high

# Go（モジュールディレクトリ）
go run golang.org/x/vuln/cmd/govulncheck@latest ./...

# Python
python -m pip install pip-audit
python -m pip_audit

# Trivy（Docker があるとき。タグではなく現行バイナリ）
docker run --rm -v ${PWD}:/src aquasec/trivy:0.70.0 fs --severity HIGH,CRITICAL --exit-code 1 /src
```

`npm audit --force` は使わない。一括メジャー上げもしない。

## やらないこと

- 全 overlay の同時起動
- 習慣モバイルアプリの Kubernetes
- `terraform apply`
- P11 スキャナへの exploit / PoC
- 未実装機能を通すためのダミーテスト
