# P09 attendance

「P09 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `attendance/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/attendance/DESIGN.md`
5. `portfolio-idea/03-attendance-time-tracking.md`
6. `attendance/chat-context/CURRENT.md`（あれば）。過去の `P09_*.md` は全読しない（不明点だけ Grep）
7. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/attendance/docs/README.md`

認証結合時は `identity-platform/DESIGN.md`。P05 予約とは統合しない。

製品コードはワークスペースの兄弟 `../pf-attendance`（`apps/api` Spring Boot、`apps/web`、`deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P09_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。従業員シードは架空のみ。
