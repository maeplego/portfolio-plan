# P08 content-platform

「P08 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル（なければ `content-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/content-platform/DESIGN.md`
5. `portfolio-idea/07-tech-blog-cms.md`
6. `portfolio-idea/09-url-shortener-analytics.md`
7. `content-platform/chat-context/` の `P08_*.md` をファイル名昇順で全て
8. 書類の更新・面接説明では `portfolio-plan/documentation.md` と `portfolio-plan/content-platform/docs/README.md`

画像は P03、3-tier は P02。overlay E は Compose デモが安定してから。

製品コードはワークスペースの兄弟:

- `../pf-content-blog` — 公開ブログ + 管理 CMS（アイデア 07）。Markdown、下書き/公開
- `../pf-content-shortener` — Go リダイレクト + 作成 API（アイデア 09）。Next.js に 302 を載せない
- `../pf-content-infra` — 単体連携 Compose（Postgres + Redis + 両方）

このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

チャット記録の次ファイルは `chat-context/P08_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
