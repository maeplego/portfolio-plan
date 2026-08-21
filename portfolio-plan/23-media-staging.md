# Media staging 手順

> **読者**: 商用準備・運用向け。採用スキムは [03-hiring.md](./03-hiring.md) → [05-review.md](./05-review.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P03 Media（Collab / Commerce 添付経路） |
| 最終更新 | 2026-08-21 |

デモ overlay では `MEDIA_ENV` 未設定（development）のまま OIDC を載せることがある。商用 staging では **`MEDIA_ENV=staging`** を明示し DEV_AUTH を禁止する。

## 商用 staging の条件

- `MEDIA_ENV=staging`（`MEDIA_DEV_AUTH=false`、`OIDC_ISSUER` 必須）
- 秘密は Git に置かない。顧客バケットは [media-platform/docs/07-customer-bucket.md](./media-platform/docs/07-customer-bucket.md)

## Compose

1. `MEDIA_ENV=staging`、`MEDIA_DEV_AUTH=false`
2. `OIDC_ISSUER` / `OIDC_INTERNAL_BASE` / `OIDC_AUDIENCE=pf-media-web`
3. 確認: `GET /v1/quota` + `X-Dev-User-Sub` → **401**

## Overlay（Collab / Commerce に同梱）

| Overlay | Media |
| --- | --- |
| `docker-desktop-b-collab-staging` | `MEDIA_ENV=staging` |
| `docker-desktop-d-commerce-staging` | 同上 |

```powershell
cd pf-cloud-k8s
.\scripts\smoke-b-collab-staging.ps1
.\scripts\cluster-smoke-b-collab-staging.ps1   # workspace + media DEV_AUTH 401
```

高速化: `pf-cloud-k8s/docs/smoke-performance.md`。

L3a 記録（2026-08-21）: Collab staging Quick smoke で media `GET /v1/quota` + `X-Dev-User-Sub` → **401**、workspace 同様 **pass**。
