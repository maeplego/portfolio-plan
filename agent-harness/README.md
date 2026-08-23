# Portable agent harness

Cursor **rules + skills** that keep agent context thin (`CURRENT.md`, no full chat dumps).  
This folder is the **exportable source**. The portfolio megaworkspace can stay large; new / separate workspaces install from here.

## What is portable vs portfolio-only

| Portable (`agent-harness/`) | Portfolio-only (`project/.cursor/skills/`) |
| --- | --- |
| `start-project` | `start-pxx` (P01–P16 map) |
| `verify-before-commit` | `verify-pf` (pf-* test matrix) |
| `record-chat-context` | — (same name; harness is canonical) |
| `write-docs` | portfolio `write-docs` overlays `02-documentation.md` paths |
| Generic always-on rules | Rules that name `portfolio-plan/` / `pf-*` |

## Install into a new project

**Preferred:** use the standalone template at `C:\dev\development\dev-template`:

```powershell
cd C:\dev\development\dev-template
.\scripts\New-Project.ps1 -Name 'My App' -TargetPath 'C:\dev\development\my-app' -GitInit
```

That copies a full app skeleton and installs this harness from `dev-template/vendor/agent-harness`.

From this repo (`project/`) you can still install harness-only into an existing folder:

```powershell
# Copy rules + skills (+ optional AGENTS / gitignore / CURRENT) into another repo
.\scripts\install-agent-harness.ps1 -TargetPath 'C:\dev\my-new-app' -SeedTemplates

# Same machine, every Cursor workspace: install skills under ~/.cursor/skills/
.\scripts\install-agent-harness.ps1 -Personal
```

`-Personal` and `-TargetPath` can be combined.

After install in a new repo:

1. Fill in `AGENTS.md` test commands and design paths
2. Open that repo (or a small multi-root workspace) — not the whole portfolio
3. Say “follow AGENTS” / use skill `start-project`

## Refresh

Re-run the install script; it overwrites harness-managed files listed in `manifest.json` only. It does **not** delete portfolio-specific skills like `start-pxx`.

## Layout

```
agent-harness/
  manifest.json
  rules/*.mdc
  skills/*/SKILL.md
  templates/
  README.md
```
