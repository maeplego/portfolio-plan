# For hiring reviewers — start here (~3 min)

| | |
| --- | --- |
| Audience | Hiring managers / technical reviewers |
| Updated | 2026-08-21 |

This is a **learning / demo / internal-evaluation** software portfolio — not a drop-in production SaaS.

## In one sentence

An ecosystem of products (`pf-*` repos) sharing an OpenID Connect IdP, shown as **customer-installable packages**, not a vendor-hosted multi-tenant SaaS.

## We do not claim

- Production SLA or warranty under the public eval license ([licensing.md](./licensing.md))
- PCI-compliant payments, labor-law-certified attendance, or tax/withholding correctness
- Live `terraform apply` to AWS, or running all 15 products at once

## Three GitHub pins

1. This meta repo (design + this page)
2. A UI product: [pf-workspace](https://github.com/maeplego/pf-workspace) or [pf-commerce](https://github.com/maeplego/pf-commerce)
3. One depth repo: identity, observability, or reliability

## Talk track (~5 min)

1. Auth (PKCE, refresh rotation) — `pf-identity`
2. Main line — workspace create, or commerce “stock=1 race” demo
3. One depth topic — traces, OpenAPI breaking CI, incident drill scoring, or recommend fail-closed

## Next

Hands-on steps (Japanese): [REVIEW.md](./REVIEW.md). Full Japanese one-pager: [HIRING.md](./HIRING.md).
