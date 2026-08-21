# For hiring reviewers — start here (~3 min)

| | |
| --- | --- |
| Audience | Hiring managers / technical reviewers |
| Updated | 2026-08-21 |

This is a **learning / demo / internal-evaluation** software portfolio — not a drop-in production SaaS.

## In one sentence

An ecosystem of products (`pf-*` repos) sharing an OpenID Connect IdP, framed as **customer-installable packages**, not a vendor-hosted multi-tenant SaaS.

## Out of scope (we do not claim)

- Production SLA or warranty under the public eval license ([15-licensing.md](./15-licensing.md))
- PCI-compliant payments, labor-law-certified attendance, or tax/withholding correctness
- Live `terraform apply` to AWS, or running all 15 products at once

## Suggested reading path (3 repos)

You do not need to review everything.

1. **This meta repo** — design and this page
2. **A UI product** — [pf-workspace](https://github.com/maeplego/pf-workspace) or [pf-commerce](https://github.com/maeplego/pf-commerce)
3. **One depth repo** — identity, observability, or reliability

## What to look for in the code

| Area | Example repo | Focus |
| --- | --- | --- |
| Auth | `pf-identity` | PKCE, redirect URI handling, refresh-token rotation |
| Main UI | workspace or commerce | Workspace create, or stock=1 concurrent purchase demo |
| Depth | o11y / portal / reliability / recommend | Traces, OpenAPI breaking CI, drill scoring, or fail-closed fallback |

## Next

Hands-on steps (Japanese): [05-review.md](./05-review.md). Full Japanese page: [03-hiring.md](./03-hiring.md).
