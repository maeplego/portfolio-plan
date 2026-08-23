# Agent bootstrap

チャット履歴だけに頼らない。**全部を先読みしない。** 地図だけ読んで、詳細はタスクに応じて開く。

1. プロジェクト ID（P01–P16）を特定する
2. そのフォルダの `AGENTS.md`（なければ `instructions.md`）— 索引のみ
3. 実装・調査なら: `portfolio-plan/<project>/DESIGN.md` の**該当節**と、対象 `pf-*` のコード
4. 状態の引き継ぎ: `<project>/chat-context/CURRENT.md`（あれば）。横断メタ作業はリポジトリ直下 `chat-context/CURRENT.md` も可。過去の `Pxx_*.md` は **全読禁止** — 不明点だけファイル名 / Grep で探す
5. 書類を書く／直すとき: skill `write-docs` と `portfolio-plan/02-documentation.md`
6. 工程の詳細・コミット規約: 必要なら `portfolio-plan/01-instructions.md`（毎回全文は不要）

「P01 を実装して」→ `identity-platform/AGENTS.md` と skill `start-pxx`。

コミット前検証は skill `verify-pf`。往復の記録は skill `record-chat-context`（`CURRENT.md` 更新 + 必要なら連番ログ 1 件）。

別ワークスペースへ汎用 skills / rules を流用するときは `agent-harness/` と `scripts/install-agent-harness.ps1`（`-Personal` で `~/.cursor/skills/`）。

`DESIGN.md` と `portfolio-plan/**/docs/` は git 管理。`chat-context/` と `.env` は管理しない。製品コードは兄弟 `../pf-*`。新規 `pf-*` は `portfolio-plan/product-repos.json` 更新後 `scripts/sync-workspace.ps1`。
