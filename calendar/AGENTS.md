# P05 calendar

「P05 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/calendar/DESIGN.md`
5. `portfolio-idea/11-booking-scheduler.md`
6. `calendar/chat-context/CURRENT.md`（あれば）。過去の `P05_*.md` は全読しない（不明点だけ Grep）
7. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/calendar/docs/README.md`

P10 結合時は `portfolio-plan/talent-platform/DESIGN.md` も読む。

製品コードはワークスペースの兄弟 `../pf-calendar`（`packages/slot-engine`, `apps/api`, `apps/web`, `apps/worker`, `deploy`）。このフォルダは設計・指示・チャット記録用。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P05_XXXXX_要約.md`（既存最大連番 + 1）。
