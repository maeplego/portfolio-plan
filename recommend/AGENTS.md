# P07 recommend

「P07 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/recommend/DESIGN.md`
5. `portfolio-idea/20-recommendation-engine.md`
6. `recommend/chat-context/CURRENT.md`（あれば）。過去の `P07_*.md` は全読しない（不明点だけ Grep）

EC 結合時は `commerce-platform/DESIGN.md`。求人結合時は `talent-platform/DESIGN.md`。

製品コードはワークスペースの兄弟 `../pf-recommend`（`apps/api`, `apps/train`, `apps/demo-web`, `packages/metrics`, `deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P07_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
