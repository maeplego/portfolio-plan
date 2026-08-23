# P11 developer-platform

「P11 を実装して」と言われたら skill `start-pxx`。全部先読みせず、必要なものだけ:

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `developer-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/developer-platform/DESIGN.md`
5. `portfolio-idea/21-repo-security-scanner.md`（scanner）
6. `portfolio-idea/29-openapi-developer-portal.md`（portal）
7. `portfolio-idea/23-cli-project-scaffolding.md`（CLI。完成扱いは P04/P06 の実テンプレ後）
8. `portfolio-idea/15-ci-pipeline-dashboard.md`
9. `portfolio-idea/08-code-review-assistant.md`
10. `developer-platform/chat-context/CURRENT.md`（あれば）。過去の `P11_*.md` は全読しない（不明点だけ Grep）

製品コードはワークスペースの兄弟:

- `../pf-developer-scanner` — 脆弱性・シークレット・Dockerfile ルールの CLI（アイデア 21）。MVP。exploit / PoC なし
- `../pf-developer-cli` — `pf-dev new` / `pf-dev scan`（アイデア 23）。テンプレは P04/P06 実体
- `../pf-developer-templates` — `go-api` と `go-next`（template.json + 実ファイル）
- `../pf-developer-portal` — 手置き OpenAPI カタログ、リファレンス、example モック、oasdiff Action / `oasdiff-gate`（アイデア 29）
- `../pf-developer-ci-dash` — 公開 GitHub Actions の読み取りダッシュボード（アイデア 15）。PAT は git に置かない
- `../pf-developer-review` — PR diff / コメントの GitHub API BFF（アイデア 08）。ローカル git パスは扱わない

`pf-developer-web` 横断シェルは未着手。scanner は overlay 非搭載。exploit / PoC は書かない。

このフォルダは設計・指示・チャット記録用。入れ子 Git は作らない。

状態の引き継ぎは `chat-context/CURRENT.md` を更新（skill `record-chat-context`）。大きな区切りだけ `chat-context/P11_XXXXX_要約.md`（既存最大連番 + 1）。秘密は書かない。
