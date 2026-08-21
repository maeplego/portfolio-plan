# Commerce staging 手順

> **読者**: 商用準備・運用向け。採用スキムは [HIRING.md](./HIRING.md) → [REVIEW.md](./REVIEW.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P06 Commerce（± P01 / P03 / P07）商用ゲート検証の入口 |
| 最終更新 | 2026-08-21 |

デモ overlay D（`cluster-smoke-d-commerce.ps1`）は gateway / order が `COMMERCE_DEV_AUTH=true` のままなので、**採用レビュー用スモーク**と **商用 staging** を分ける。

## 商用 staging の条件

- `COMMERCE_ENV=staging`（`COMMERCE_DEV_AUTH=false`、`OIDC_ISSUER` 必須）
- 対象プロセス: commerce gateway（`apps/api`）と order
- 秘密は Git に置かない。本格決済／PCI は別ゲート（名乗らない）

## Compose で組む

1. P01: `IDENTITY_ENV=staging`（Collab と同じ）
2. gateway / order: `COMMERCE_ENV=staging`、`COMMERCE_DEV_AUTH=false`、`OIDC_ISSUER` / `OIDC_INTERNAL_BASE`
3. storefront: 既存 OIDC クライアント設定
4. 確認: ログイン必須経路。`X-Dev-User-Sub` だけでは注文 API が通らない

Collab ゲートの再利用項目は [production-definition.md](./production-definition.md)。層は [verification.md](./verification.md)。

## Overlay

| Overlay | 用途 |
| --- | --- |
| `docker-desktop-d-commerce` | デモ／採用スモーク（DEV_AUTH 可、`/demo`） |
| `docker-desktop-d-commerce-staging` | 商用 staging（`COMMERCE_ENV=staging`、DEV_AUTH 禁止） |

```powershell
cd pf-cloud-k8s
.\scripts\smoke-d-commerce-staging.ps1   # kustomize + dry-run
```

フル cluster スモーク:

```powershell
cd pf-cloud-k8s
.\scripts\cluster-smoke-d-commerce-staging.ps1   # または -SkipBuild（ホストにイメージがあるとき）
```

確認: gateway `/health`、`X-Dev-User-Sub` で cart が **401**、storefront 到達。

L3a 記録（2026-08-21）: DEV_AUTH 401・`commerce-api.localhost/health`・storefront 到達を確認して **pass**。
