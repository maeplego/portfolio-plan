# Portfolio review (recruiters)

| Item | Value |
| --- | --- |
| Audience | Hiring managers and engineers reviewing this portfolio |
| Default path | Browser + optional Docker Compose. **Kubernetes is optional** |
| Last updated | 2026-08-19 |

Last verified on this machine (2026-08-19):

- `.\scripts\review-up.ps1 -Pack p04 -UseLocalImages` — `3006` / `8096` / `8097` health 200. Then `review-down.ps1 -Pack p04`.
- `.\scripts\review-up.ps1 -Pack p06 -UseLocalImages` — storefront `/` and `/demo` 200, `8099/health` and `8110/health` `{"ok":true}`, seed SKU `MUG-1`. Then `review-down.ps1 -Pack p06`. An old `commerce-pg` volume that only had the `commerce` database is healed by `commerce-db-init` (creates `catalog` / `inventory` / `orders` / `gateway` if missing).

## 0. Browser only (about 5 minutes)

GitHub repos in the `pf-*` family plus this meta repo. Look at:

1. **P01 identity** — authorize, consent, PKCE, token, JWKS (`pf-identity`)
2. **P04 workspace or P06 commerce** — one product with a UI (`pf-workspace` or `pf-commerce`)
3. **One depth pick** — P02 observability, P11 developer portal, or P12 incidents

Architecture and “what we skipped” live in `portfolio-plan/00-overview.md` and each `portfolio-plan/<project>/DESIGN.md`.

There is no hosted always-on IdP. AWS `terraform apply` is **out of scope**.

## 1. One Compose pack (Docker Desktop, Kubernetes off)

From `pf-cloud-k8s` (sibling clones of the product repos are required):

```powershell
cd pf-cloud-k8s
$env:GHCR_OWNER = "github-username"   # after those repos publish public GHCR images
.\scripts\review-up.ps1 -Pack p01-p03   # or p04 / p06
```

`review-up.ps1` with GHCR (`GHCR_OWNER` set) runs `docker compose pull` then `up -d --no-build`.

On a developer machine, **`-UseLocalImages` builds** from each product `deploy/compose.yaml` (first run is slow; later runs use cache). You do not need to pre-tag `pf-*:latest` by hand.

| Pack | What you see | URLs |
| --- | --- | --- |
| `p01-p03` | IdP + admin + sample RP + media (dev user) | http://localhost:8080 · http://localhost:3002 · http://localhost:3001 · http://localhost:3004 |
| `p04` | Workspace kanban/wiki/chat shell | http://localhost:3006 |
| `p06` | Storefront, last-unit demo, ops grid | http://localhost:3009 · `/demo` · http://localhost:3010 · http://localhost:8099/health · http://localhost:8110/health |

Developer machine without GHCR:

```powershell
.\scripts\review-up.ps1 -Pack p04 -UseLocalImages
.\scripts\review-up.ps1 -Pack p06 -UseLocalImages
```

First run compiles images. Later runs reuse the Docker cache. `p06` also starts payment, notify, BFF, and ops-web.

## 3-point live demo (when Compose is up)

**A. Auth (pack `p01-p03`)**

1. Open http://localhost:3001 (sample RP) and complete login
2. Demo user is seeded by the IdP compose stack (see `pf-identity` README). Not a production account
3. Admin UI http://localhost:3002

**B. Main product (pick one)**

- P04: http://localhost:3006 — create a workspace (dev header auth in Compose)
- P06: http://localhost:3009/demo — last-unit stock (one checkout wins)

**C. Depth (optional, still not K8s)**

- P02: `pf-cloud-o11y/deploy` Compose and Grafana (see that README)

## Known limits

- Compose packs use **dev auth** for media / workspace / commerce. Full OIDC across apps is the **optional** K8s foundation overlay
- GHCR tags exist only after each `pf-*` repo runs the example workflow in `pf-cloud-k8s/docs/example-github-push-ghcr.yml`. Until then use `-UseLocalImages` (builds locally)
- 12 GB Docker Desktop Kubernetes, ~28 image import, overlay switching: **not** the recruiter path
- No real card numbers, no real household data, no production AWS

## Cleanup

When you are done: `.\scripts\cleanup.ps1` (from `pf-cloud-k8s`; default stops K8s overlays only). Compose volumes: `.\scripts\review-down.ps1 -Pack p04` or `-Pack p06`, or `.\scripts\cleanup.ps1 -Level full` (confirms unless `-Yes`).
