# Payroll staging 手順

> **読者**: 商用準備・運用向け。採用スキムは [HIRING.md](./HIRING.md) → [REVIEW.md](./REVIEW.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P16 payroll（± P01。入力ソースは P09。f-ops 同梱） |
| 最終更新 | 2026-08-21 |

デモ overlay F は `PAYROLL_DEV_AUTH=true` 可。商用 staging は Attendance と同じ `docker-desktop-f-ops-staging` に載せる。**源泉・社保・振込確定・法令準拠は名乗らない**（MN3 Go 前）。

## 商用 staging の条件

- `PAYROLL_ENV=staging`（`PAYROLL_DEV_AUTH=false`、OIDC issuer をセット）
- 秘密は Git に置かない
- UI／API は `legalEffect: false` のまま

## Overlay

| Overlay | 用途 |
| --- | --- |
| `docker-desktop-f-ops` | デモ（DEV_AUTH 可。`payroll.localhost`） |
| `docker-desktop-f-ops-staging` | 商用 staging（Attendance + Payroll とも ENV=staging） |

```powershell
cd pf-cloud-k8s
.\scripts\smoke-f-ops-staging.ps1                 # kustomize + dry-run（ATTENDANCE_* + PAYROLL_*）
.\scripts\cluster-smoke-f-ops-staging.ps1         # 既定 Quick（idp + attendance + payroll）
.\scripts\cluster-smoke-f-ops-staging.ps1 -Full
```

確認: `payroll.localhost/health`、`POST /v1/exports/payroll` + `X-Dev-User-Sub` のみ → **401**。

関連: [attendance-staging.md](./attendance-staging.md)、[mn-payroll-tax.md](./mn-payroll-tax.md)。
