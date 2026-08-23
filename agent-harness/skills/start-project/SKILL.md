---
name: start-project
description: >-
  Bootstraps work in a repo that uses the portable agent harness. Use when
  starting implementation or investigation in a new or unfamiliar project, or
  when the user says follow AGENTS.md / CURRENT.md. Loads only the map and
  CURRENT.md — never the full chat-context archive.
---

# Start project (minimal context)

## Steps

1. Read root `AGENTS.md` (index). If missing, ask where the design map lives.
2. Open `DESIGN.md` (path from AGENTS) — **relevant sections only**.
3. If `chat-context/CURRENT.md` exists, read it. Optionally `DECISIONS.md`.
4. **Do not** read every file under `chat-context/`. Grep archives only when stuck.
5. Change code in the paths AGENTS lists; keep unrelated packages out of scope.

## After starting

- Before commit: skill `verify-before-commit`
- End of a meaningful turn: skill `record-chat-context`
