# P08 content-platform

「P08 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `content-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/content-platform/DESIGN.md`
5. `portfolio-idea/07-tech-blog-cms.md`
6. `portfolio-idea/09-url-shortener-analytics.md`
7. `content-platform/chat-context/CURRENT.md`（あれば）。過去の `P08_*.md` は全読しない（不明点だけ Grep）
8. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/content-platform/docs/README.md`

画像は P03、3-tier は P02。overlay E は Compose デモが安定してから。

製品コードはワークスペースの兄弟:

- `../pf-content-blog` — 公開ブログ + 管理 CMS（アイデア 07）。Markdown、下書き/公開
- `../pf-content-shortener` — Go リダイレクト + 作成 API（アイデア 09）。Next.js に 302 を載せない
- `../pf-content-infra` — 単体連携 Compose（Postgres + Redis + 両方）

このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P08_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
