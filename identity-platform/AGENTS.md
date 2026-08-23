# P01 identity-platform

「P01 を実装して」と言われたら skill `start-pxx`。先に全部読まない。必要ならこの順:

1. 本ファイル（索引）
2. `portfolio-plan/identity-platform/DESIGN.md` の該当節
3. `portfolio-idea/14-oauth-oidc-identity-provider.md`（必要なとき）
4. `identity-platform/chat-context/CURRENT.md`（あれば）。過去の `P01_*.md` は全読しない（不明点だけ Grep）
5. 工程の詳細が要るときだけ `portfolio-plan/01-instructions.md` / `portfolio-plan/00-overview.md`

製品コードはワークスペースの兄弟 `../pf-identity`（`apps/server`, `deploy`）。このフォルダは設計・指示・チャット記録用。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P01_XXXXX_要約.md`（既存最大連番 + 1）。
