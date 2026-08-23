# P12 reliability-platform

「P12 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `reliability-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/reliability-platform/DESIGN.md`
5. `portfolio-idea/04-incident-management.md`
6. `portfolio-idea/30-sre-runbook-simulator.md`
7. `reliability-platform/chat-context/CURRENT.md`（あれば）。過去の `P12_*.md` は全読しない（不明点だけ Grep）

観測連携時は `portfolio-plan/cloud-platform/DESIGN.md`。シナリオの題材に P06 を使う場合は `commerce-platform/DESIGN.md`（読み取り・仮想化のみ）。

製品コードはワークスペースの兄弟 `../pf-reliability`（`apps/api`, `apps/web`, `packages/scenario`, `packages/openapi`, `deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P12_XXXXX_要約.md`（既存最大連番 + 1）。自動 rollback / 破壊的な実オペは実装しない。秘密は書かない。
