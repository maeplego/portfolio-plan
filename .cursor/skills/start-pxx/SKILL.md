---
name: start-pxx
description: >-
  Bootstraps work on a portfolio project (P01–P16). Use when the user names a
  Pxx, says implement/investigate a platform, or starts a session on identity,
  media, commerce, calendar, workspace, or other pf-* apps. Loads only the map
  and CURRENT.md — never the full chat-context history.
---

# Start Pxx (minimal context)

## Steps

1. Map user wording to an ID using `portfolio-plan/01-instructions.md` project table (or root `AGENTS.md`).
2. Read **only** that folder’s `AGENTS.md` (or `instructions.md`).
3. Read `portfolio-plan/<project>/DESIGN.md` sections relevant to the ask (not the whole file if large).
4. If `<project>/chat-context/CURRENT.md` exists, read it. Optionally `DECISIONS.md`.
5. **Do not** read all `chat-context/Pxx_*.md`. If something is unclear, Grep those filenames/contents for keywords.
6. Open the sibling `pf-*` paths listed in that AGENTS.md for code changes.
7. Prefer a small multi-root workspace (project + 1–3 product repos). Avoid treating every `pf-*` as in-scope.

## After starting

- Implement against tests in the product repo.
- Before commit: skill `verify-pf`.
- End of meaningful turn: skill `record-chat-context`.
