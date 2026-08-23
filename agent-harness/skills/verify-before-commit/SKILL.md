---
name: verify-before-commit
description: >-
  Runs the project's documented tests before committing. Use when the user asks
  to commit, finish a feature, or verify changes. Reads test commands from
  AGENTS.md or package scripts — does not invent a portfolio-specific matrix.
---

# Verify before commit

1. Identify which package/repo changed (`git status`).
2. Read test commands from root `AGENTS.md` (or that package's README).
3. Run those tests. Do not commit red.
4. `git status` / diff: no `.env`, keys, PEMs, or `chat-context/`.
5. If AGENTS has no test line, ask the user or infer from `package.json` / `go.mod` / `pyproject.toml` once — then write the command into AGENTS for next time.
