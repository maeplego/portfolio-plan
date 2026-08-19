# P15 habit-tracker

「P15 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル（なければ `habit-tracker/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/habit-tracker/DESIGN.md`
5. `portfolio-idea/22-mobile-habit-tracker.md`
6. `habit-tracker/chat-context/` の `P15_*.md` をファイル名昇順で全て
7. 書類の更新・面接説明では `portfolio-plan/documentation.md` と `portfolio-plan/habit-tracker/docs/README.md`

認証結合時は `identity-platform/DESIGN.md`。P14 とはドメインを共有しない。

製品コードはワークスペースの兄弟:

- `../pf-habit-mobile` — Expo (React Native)、SQLite、ストリーク純関数
- `../pf-habit-api` — 同期 API（Hono + PostgreSQL）。モバイル本体は K8s に載せない

このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P15_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。実在の習慣ログは記録にもコードにも入れない。
