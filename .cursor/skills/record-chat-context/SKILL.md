---
name: record-chat-context
description: >-
  Updates agent handoff state under chat-context after a meaningful portfolio
  turn. Use at end of implementation/investigation turns, or when the user asks
  to record context. Prefer CURRENT.md; do not dump full chat history into the
  prompt or require reading every Pxx_*.md.
---

# Record chat-context

Target: `project/<folder>/chat-context/` (gitignore). Never stage into git.

## Always (meaningful turn)

Create or **overwrite** `CURRENT.md` (keep ≤ ~40 lines):

```markdown
# CURRENT Pxx

- Updated: YYYY-MM-DD
- Goal:
- Decisions:
- Open questions:
- Next:
- Touched repos:
```

## Sometimes (milestone / hard decision)

Add one new archive file: `Pxx_NNNNN_short-summary.md` (max existing N + 1).
Do **not** create a new numbered file for every trivial exchange.

Optional: append durable decisions to `DECISIONS.md`.

## Never

- Secrets, tokens, passwords, PEMs
- “Read all chat-context files” instructions in new notes
