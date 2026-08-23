---
name: verify-pf
description: >-
  Runs the correct tests before committing a portfolio product repo. Use when
  the user asks to commit, finish a feature, or verify pf-identity, pf-media,
  pf-commerce, pf-calendar, pf-workspace, or other pf-* changes.
---

# Verify pf-* before commit

Run tests in the **product repo** that changed. Do not commit red.

| Repo | Command (cwd) |
| --- | --- |
| pf-identity | `apps/server`: `go test ./...` |
| pf-cloud-o11y | `apps/demo-api`: `go test ./...` |
| pf-cloud-k8s | client dry-run: `kubectl apply -k deploy/overlays/portfolio-integration --dry-run=client --load-restrictor LoadRestrictionsNone` (if kubectl available) |
| pf-cloud-aws | `terraform fmt` + `terraform -chdir=envs/dev-p09-attendance init -backend=false` then `validate` |
| pf-media | `apps/api`: `go test ./...`; processor: `apps/processor` `npm test` if touched |
| pf-workspace | `apps/api` `go test ./...`; `apps/collab` / `apps/web` `npm test` if touched; web `npm run build` if UI |
| pf-calendar | repo root: `npm test` |
| pf-commerce | repo root: `go test ./...`; `apps/bff` `npm test` if touched |
| pf-recommend | root: `python -m pytest` (env with `.[dev,api,train]`) |
| pf-talent-api / pf-talent-web | follow that repo’s AGENTS / package scripts |
| pf-developer-ci-dash / pf-developer-review | `go test ./...` |
| pf-content-blog / shortener | package scripts / `npm test` if present |
| pf-finance | root: `npm test` |
| pf-data | root: `python -m pytest` |
| pf-habit-mobile / pf-habit-api | `npm test` |
| pf-attendance / pf-payroll | root: `npm test` |

Also: `git status` / diff — no `.env`, keys, or `chat-context/`.
