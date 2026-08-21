# Collab staging 手順

| 項目 | 値 |
| --- | --- |
| 対象 | P01 + P04（± P03）商用ゲート検証 |
| 最終更新 | 2026-08-21 |

デモ用 overlay B（`cluster-smoke-b-collab.ps1`）は API が `WORKSPACE_DEV_AUTH=true` のままなので、**採用レビュー用スモーク**と **商用 staging** を分ける。

## 商用 staging の条件

- `IDENTITY_ENV=staging`（一時鍵・memory 禁止）
- `WORKSPACE_ENV=staging`（`WORKSPACE_DEV_AUTH=false`、`OIDC_ISSUER` 必須、org 必須）
- 秘密は Git に置かない

## Compose で組む（推奨・再現しやすい）

1. P01: `IDENTITY_ENV=staging`、`IDENTITY_STORE=postgres`、`IDENTITY_RSA_PRIVATE_KEY_PATH=…`、`IDENTITY_DEV_GENERATE_KEYS=false`
2. P04 API: `WORKSPACE_ENV=staging`、`WORKSPACE_DEV_AUTH=false`、`OIDC_ISSUER` / `OIDC_INTERNAL_BASE` / `OIDC_AUDIENCE`
3. P04 Web: 通常の OIDC クライアント設定（`OIDC_CLIENT_ID=pf-workspace-web` 等）
4. 確認: ログイン → ホーム → org 切替。`X-Dev-User-Sub` では API が 401

詳細チェックリストは [production-definition.md](./production-definition.md)。BYO は [portability-byo-idp.md](./portability-byo-idp.md)。層の地図は [verification.md](./verification.md)。

## Overlay

| Overlay | 用途 |
| --- | --- |
| `docker-desktop-b-collab` | デモ／採用スモーク（API は DEV_AUTH 可） |
| `docker-desktop-b-collab-staging` | 商用 staging（`WORKSPACE_ENV=staging`、DEV_AUTH 禁止） |

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-b-collab-staging.ps1   # DEV_AUTH 401 と OIDC redirect を確認
# イメージがホストにあるとき: -SkipBuild
```

L3a 記録（2026-08-21）: DEV_AUTH 401・Ingress health・`workspace.localhost` → `idp.localhost/authorize` を確認して **pass**（初回はイメージ load 後の postgres Ready 待ちが PowerShell Stop で中断。`load-images.ps1` / `up-b-collab-staging.ps1` を修正済み）。

詳細チェックリストは [production-definition.md](./production-definition.md)。BYO は [portability-byo-idp.md](./portability-byo-idp.md) と `pf-workspace/deploy/byo-oidc/`。層の位置づけは [verification.md](./verification.md) の L3a。