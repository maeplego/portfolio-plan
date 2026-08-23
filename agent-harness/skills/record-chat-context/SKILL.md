---
name: record-chat-context
description: >-
  Updates agent handoff state under chat-context after a meaningful turn. Use
  at end of implementation/investigation, or when the user asks to record
  context. Prefer CURRENT.md; never require reading every archive log.
---

# Record chat-context

Target: `chat-context/` (gitignore). Never stage into git.

## Always (meaningful turn)

Create or **overwrite** `CURRENT.md` (keep ≤ ~40 lines):

```markdown
# CURRENT

- Updated: YYYY-MM-DD
- Goal:
- Decisions:
- Open questions:
- Next:
- Touched paths:
```

## Sometimes (milestone / hard decision)

Add one archive file: `{PREFIX}_{NNNNN}_short-summary.md` (max existing N + 1).
Do **not** create a numbered file for every trivial exchange.

Optional: append durable decisions to `DECISIONS.md`.

## Never

- Secrets, tokens, passwords, PEMs
- Instructions that say “read all chat-context files”
