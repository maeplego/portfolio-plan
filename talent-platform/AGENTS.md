# P10 talent-platform

「P10 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/01-instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/talent-platform/DESIGN.md`
5. `portfolio-idea/27-job-matching-platform.md`
6. `talent-platform/chat-context/` の `P10_*.md` をファイル名昇順で全て
7. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/talent-platform/docs/README.md`

面接予約の結合時は `calendar/AGENTS.md` と `portfolio-plan/calendar/DESIGN.md`。推薦結合時は `recommend/instructions.md`。

製品コードはワークスペースの兄弟:

- `../pf-talent-api` — 求人・応募・検索の正。OpenAPI 相当は docs `05-api.md`
- `../pf-talent-web` — 候補者検索 UI、企業の求人管理、応募者一覧（ポート 3010）

`pf-talent-search` は作らない。検索は API 内の `tsvector` + `pg_trgm`。件数が増えたら indexer を分離する。OpenSearch はこの段階では足さない。

このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P10_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
