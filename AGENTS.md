# Agent bootstrap

実装・調査の前に、チャット履歴だけに頼らず次を読む。

1. `portfolio-plan/instructions.md`（工程の正本）
2. プロジェクト ID（P01–P15）を特定する
3. そのフォルダの `AGENTS.md`（なければ `instructions.md`）
4. そこに列挙された overview / `DESIGN.md` / 元アイデア md
5. そのフォルダの `chat-context/` をファイル名昇順で全部

「P01 を実装して」の読み込み対象は `identity-platform/AGENTS.md`。

`DESIGN.md` と指示ファイルは git 管理する。`chat-context/` と `.env` は管理しない。製品コードは兄弟ディレクトリの製品リポジトリ（例: `../pf-identity`）に置く。
