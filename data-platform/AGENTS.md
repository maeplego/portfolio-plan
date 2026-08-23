# P13 data-platform

「P13 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `data-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/data-platform/DESIGN.md`
5. `portfolio-idea/19-etl-data-pipeline.md`
6. `data-platform/chat-context/CURRENT.md`（あれば）。過去の `P13_*.md` は全読しない（不明点だけ Grep）

ソース結合時は `commerce-platform/DESIGN.md` および/または `talent-platform/DESIGN.md`。最初の DAG は架空 CSV。P06 / P10 をソースにした本番パイプライン扱いはしない。

製品コードはワークスペースの兄弟 `../pf-data`（`ingest`, `transform`, `orchestrate`, `seeds`, `deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P13_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
