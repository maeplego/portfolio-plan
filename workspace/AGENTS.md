# P04 workspace

「P04 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `workspace/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/workspace/DESIGN.md`
5. `portfolio-idea/01-sprint-kanban-task-manager.md` ほか DESIGN 列挙分
6. `workspace/chat-context/CURRENT.md`（あれば）。過去の `P04_*.md` は全読しない（不明点だけ Grep）

7. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/workspace/docs/README.md`

製品コードはワークスペースの兄弟 `../pf-workspace`（`apps/api`, `apps/collab`, `apps/web`, `deploy`）。このフォルダは設計・指示・チャット記録用。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P04_XXXXX_要約.md`（既存最大連番 + 1）。
