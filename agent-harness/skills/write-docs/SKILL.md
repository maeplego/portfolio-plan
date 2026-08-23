---
name: write-docs
description: >-
  Writes or updates human-facing project documentation (requirements, external
  specs, internal design, test specs, API docs). Use when the user asks for
  docs/, DESIGN.md updates, 要件, 仕様, or documentation standards.
---

# Write docs

1. Follow the project's documentation standard if present (else harness rule `02-documentation`).
2. Short implementation design stays in `DESIGN.md`.
3. Human-facing sets go under `docs/` once real work exists — no empty trees.
4. Precedence: **tests/code → DESIGN.md → docs/**
5. Never claim unimplemented behavior as acceptance criteria.
