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

詳細チェックリストは [production-definition.md](./production-definition.md)。BYO は [portability-byo-idp.md](./portability-byo-idp.md)。

## Overlay B（デモ）との関係

| | Overlay B スモーク | 商用 staging |
| --- | --- | --- |
| DEV_AUTH | API true（ヘッダ検証） | false |
| 用途 | クラスタ配線・health | 本番ゲート |
| 起動 | `pf-cloud-k8s` の `up-b-collab.ps1` | 上記 Compose または overlay に staging パッチを後から適用 |

## 観測

P02 Collector へ OTLP。アラート例は `pf-cloud-o11y/deploy/prometheus/alerts.yml`（Collector up）。
