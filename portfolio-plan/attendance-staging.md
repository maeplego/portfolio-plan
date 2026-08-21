# Attendance staging 手順

| 項目 | 値 |
| --- | --- |
| 対象 | P09 Attendance（± P01。f-ops 同梱の P12/P14/P15 はデモ用のまま可） |
| 最終更新 | 2026-08-21 |

デモ overlay F（`cluster-smoke-f-ops.ps1`）は `ATTENDANCE_DEV_AUTH=true` のままなので、**採用レビュー用スモーク**と **商用 staging** を分ける。労基・給与計算は名乗らない。

## 商用 staging の条件

- `ATTENDANCE_ENV=staging`（`ATTENDANCE_DEV_AUTH=false`、`ATTENDANCE_OIDC_ISSUER` 必須）
- 秘密は Git に置かない

## Overlay

| Overlay | 用途 |
| --- | --- |
| `docker-desktop-f-ops` | デモ／採用スモーク（DEV_AUTH 打刻可） |
| `docker-desktop-f-ops-staging` | 商用 staging（ENV=staging、DEV_AUTH 禁止） |

```powershell
cd pf-cloud-k8s
.\scripts\smoke-f-ops-staging.ps1                 # kustomize + dry-run
.\scripts\cluster-smoke-f-ops-staging.ps1         # 既定 Quick
.\scripts\cluster-smoke-f-ops-staging.ps1 -Full   # 全イメージ
```

高速化: `pf-cloud-k8s/docs/smoke-performance.md`。

確認: attendance `/health` `/ready`、`POST /v1/punches` + `X-Dev-User-Sub` → **401**。

L3a 記録（2026-08-21）: Quick cluster smoke **pass**（DEV_AUTH 401・`attendance-api.localhost/health`。ビルド対象 3 イメージ）。
