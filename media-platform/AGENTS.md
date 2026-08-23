# P03 media-platform

「P03 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/media-platform/DESIGN.md`
5. `portfolio-idea/13-file-storage-sharing.md`
6. `portfolio-idea/28-serverless-image-pipeline.md`
7. `media-platform/chat-context/CURRENT.md`（あれば）。過去の `P03_*.md` は全読しない（不明点だけ Grep）

製品コードはワークスペースの兄弟 `../pf-media`（`apps/api`, `apps/processor`, `apps/web`, `deploy`）。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P03_XXXXX_要約.md`（既存最大連番 + 1）。
