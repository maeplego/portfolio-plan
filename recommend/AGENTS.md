# P07 recommend

「P07 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/recommend/DESIGN.md`
5. `portfolio-idea/20-recommendation-engine.md`
6. `recommend/chat-context/` の `P07_*.md` をファイル名昇順で全て

EC 結合時は `commerce-platform/DESIGN.md`。求人結合時は `talent-platform/DESIGN.md`。

製品コードはワークスペースの兄弟 `../pf-recommend`（`apps/api`, `apps/train`, `apps/demo-web`, `packages/metrics`, `deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P07_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
