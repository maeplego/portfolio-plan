# P09 attendance

「P09 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル（なければ `attendance/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/attendance/DESIGN.md`
5. `portfolio-idea/03-attendance-time-tracking.md`
6. `attendance/chat-context/` の `P09_*.md` をファイル名昇順で全て
7. 書類の更新・面接説明では `portfolio-plan/documentation.md` と `portfolio-plan/attendance/docs/README.md`

認証結合時は `identity-platform/DESIGN.md`。P05 予約とは統合しない。

製品コードはワークスペースの兄弟 `../pf-attendance`（`apps/api` Spring Boot、`apps/web`、`deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P09_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。従業員シードは架空のみ。
