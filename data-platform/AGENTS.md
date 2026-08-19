# P13 data-platform

「P13 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル（なければ `data-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/data-platform/DESIGN.md`
5. `portfolio-idea/19-etl-data-pipeline.md`
6. `data-platform/chat-context/` の `P13_*.md` をファイル名昇順で全て

ソース結合時は `commerce-platform/DESIGN.md` および/または `talent-platform/DESIGN.md`。最初の DAG は架空 CSV。P06 / P10 をソースにした本番パイプライン扱いはしない。

製品コードはワークスペースの兄弟 `../pf-data`（`ingest`, `transform`, `orchestrate`, `seeds`, `deploy`）。このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P13_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
