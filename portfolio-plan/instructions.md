# 全プロジェクト共通の実装指示

Cursor ルール（`.cursor/rules/`）はこのファイルの要約である。矛盾したら **本ファイルを正** とする。

「P01 を実装して」のようにプロジェクトを指定されたら、必ず次を読む。

1. 本ファイル
2. 対象プロジェクトの `AGENTS.md`（なければ `instructions.md`）
3. そこに列挙された `00-overview.md` / `DESIGN.md` / 元アイデア markdown
4. 対象プロジェクトの `chat-context/` 配下を **ファイル名の昇順** で全て

以降のチャットでも、回答や実装の前にコンテキストファイル一式を読み直す。

## プロジェクトフォルダ

| ID | フォルダ | 指示ファイル |
| --- | --- | --- |
| P01 | `identity-platform/` | `identity-platform/AGENTS.md` |
| P02 | `cloud-platform/` | `cloud-platform/AGENTS.md` |
| P03 | `media-platform/` | `media-platform/AGENTS.md` |
| P04 | `workspace/` | `workspace/instructions.md` |
| P05 | `calendar/` | `calendar/AGENTS.md` |
| P06 | `commerce-platform/` | `commerce-platform/instructions.md` |
| P07 | `recommend/` | `recommend/instructions.md` |
| P08 | `content-platform/` | `content-platform/instructions.md` |
| P09 | `attendance/` | `attendance/instructions.md` |
| P10 | `talent-platform/` | `talent-platform/AGENTS.md` |
| P11 | `developer-platform/` | `developer-platform/AGENTS.md` |
| P12 | `reliability-platform/` | `reliability-platform/instructions.md` |
| P13 | `data-platform/` | `data-platform/instructions.md` |
| P14 | `personal-finance/` | `personal-finance/instructions.md` |
| P15 | `habit-tracker/` | `habit-tracker/instructions.md` |

設計資料（`portfolio-plan/<project>/DESIGN.md`）と実装ルート（`<project>/`）は場所が違う。実装・チャット記録は実装ルート側に置く。

## Git に入れないもの

次は **どのリポジトリにもコミットしない。**

- `DESIGN.md` は git 管理する（設計の履歴が必要なため）
- `<project>/chat-context/`（チャット記録。秘密が混ざる可能性がある）
- `.env`、`.env.local`、秘密鍵、PEM、証明書秘密鍵、クラウドキー
- 個人情報・本番相当のダンプ

この `project` リポジトリはアイデア・設計・共通指示・Cursor ルールを管理する。製品コードは **兄弟ディレクトリの製品リポジトリ**（例: `../pf-identity`）に置く。入れ子の `.git` は作らない。

## VS Code / Cursor ワークスペース

複数の `pf-*` を同時に開くときは `portfolio.code-workspace` を使う。正本は `portfolio-plan/product-repos.json` である。

新しい製品リポジトリを作ったら:

1. `portfolio-plan/product-repos.json` に `{ "name": "pf-…", "path": "../pf-…", "project": "Pxx" }` を追加する
2. `project/` で `.\scripts\sync-workspace.ps1` を実行する（存在しない path は警告してスキップ）
3. 対象プロジェクトの `AGENTS.md` に製品リポジトリパスを書く（既存 P01–P03 と同様）

`portfolio.code-workspace` は手編集せず、上記スクリプトで再生成する。

## チャット記録

各プロジェクトの `chat-context/` は gitignore 済み。

- 一往復（ユーザー発言 + その回の方針・結果）ごとに **新規ファイル 1 つ**
- 既存ファイルを追記して履歴を混ぜない
- ファイル名: `{ID}_{5桁連番}_{内容の要約}.md`
  - 例: `P01_00001_engineering-standards-and-start.md`
  - 連番は既存の最大 + 1。欠番を埋めない
- 含めるもの: 日時、ユーザー依頼の要約、前提、読んだファイル、決定事項、実装・調査結果、次に残っていること
- 秘密（パスワード、トークン、鍵）は記録しない。必要なら「環境変数 `X` を設定した」とだけ書く

## 要件・仕様・設計などの書類

人間向けの正式書類（要件定義、外部仕様、内部設計、テスト仕様、API、図表）の置き方と必須セットは `portfolio-plan/documentation.md` を正とする。

- 実装チャット用の短い設計は従来どおり `portfolio-plan/<project>/DESIGN.md`
- 面接・レビュー用は `portfolio-plan/<project>/docs/`（Git 管理。`chat-context/` とは別）
- 未着手 Pxx に空の `docs/` は作らない
- 矛盾したらテストとコードが正。次に `DESIGN.md`。`docs/` は追随する
- 「書類を書いて」と言われたら `documentation.md` の必須セットを確認し、見本は `calendar/docs/`

## コミットの粒度

対象は各 `pf-*` リポジトリ。親リポジトリは指示やアイデアの変更時のみ。

1. **テストを実行し、失敗があれば直す。赤のままコミットしない**
2. メソッド、小さな純関数、リポジトリ関数など、意図の単位で `git add` してコミットする
3. 画面やエンドポイント一式がつながったときも、まとまりとしてコミットする
4. リファクタだけ、テスト追加だけ、ドキュメントだけ、も別コミットにする
5. メッセージは本文で「なぜ」を書く。`.env` や `chat-context/` を stage しない
6. `git add -A` で chat-context や `.env` を巻き込まない。パスを明示する
7. `--no-verify`、`--amend`（条件外）、force push、config 変更はしない
8. フックが失敗したら、直して **新しいコミット** にする

Windows では PowerShell のヒアドキュメントを使ってよい。

```powershell
git commit -m @"
feat(password): Argon2id のハッシュと検証を追加

平文を保存せず、パラメータ付き PHC 文字列で後からコストを上げられるようにする。
"@
```

## テスト

- 純論理（PKCE、redirect 完全一致、金額、日付境界など）は DB なしの単体テスト
- ハンドラは httptest。依存はインタフェース + メモリ実装を基本にする
- Postgres 等が必要なテストは `integration` タグか Testcontainers。失敗時にスキップして緑を偽装しない
- コミット直前に対象パッケージのテストを再実行する
- 脆弱性の exploit / PoC は書かない（診断ツールでも同様）

## コード品質

- 関数は一つの理由で変わる大きさに保つ。長くなったらリファクタしてからコミット
- コメントは「なぜこの制約があるか」「仕様のどの要求か」を書く。コードの読み上げをしない
- 公開 API とセキュリティ境界（認可、redirect、トークン）には必ずテストを先か同時に付ける
- エラーは握りつぶさない。ログに秘密を出さない

## 機密とリポジトリセキュリティ

- 設定は環境変数。サンプルは `.env.example` のみ（ダミー値）
- 開発用鍵は起動時生成またはボリューム。リポジトリに PEM を置かない
- Cookie は `HttpOnly`。本番相当は `Secure`。SameSite を明示する
- 依存は既存の枯れた暗号ライブラリを使う。自前で署名・ハッシュプロトコルを発明しない
- `.gitignore` に `.env`、鍵、`chat-context/`、IDE ゴミ、カバレッジファイルを入れる
- コミット前に `git status` と diff で秘密が混ざっていないか確認する
- 公開前提の README に「学習用であり本番 IdP / 本番基盤の置き換えではない」と書く（該当製品）

## 実装の進め方（共通）

- 単独で `compose up` またはテストが通る状態を優先する
- 他プロジェクトへのハード依存はスタブで開始してよい（overview の代替表）
- ID は ULID、時刻は timestamptz、金額は整数、API 名は仕様どおり

## Kubernetes マニフェスト（連携デモ）

各 `pf-*` 製品リポジトリに **Compose と並行** で `deploy/k8s/` を置く。manifest の束ね役は兄弟 `pf-cloud-k8s`（overlay で参照）。

### ディレクトリ

```
pf-*/
  deploy/
    compose.yaml          # 単体デモ（必須）
    .env.example
    k8s/
      kustomization.yaml  # 当製品の Deployment / Service / ConfigMap
      deployment-*.yaml
      service-*.yaml
```

- **本文は製品側**、`pf-cloud-k8s` は base + overlay + 他製品 kustomization への `resources:` 参照
- overlay 名: `portfolio-integration`（初版）。手順は `portfolio-plan/integration-demo.md`

### 必須規約

| 項目 | 規約 |
| --- | --- |
| ヘルス | `GET /health`（liveness）、`GET /ready`（readiness probe） |
| 秘密 | Git に平文 Secret を置かない。`.env.example` + overlay 用 `secretGenerator`（ローカル）または外部注入 |
| 観測 | `OTEL_EXPORTER_OTLP_ENDPOINT` で platform の Collector を指す（連携 overlay 時） |
| イメージ | 各製品 Dockerfile と同じ。tag は overlay で上書き可 |
| DB | 連携時は platform Postgres の **別 DB 名**（例: `identity`, `media`）。単体 Compose は従来どおり専用 Postgres 可 |
| Ingress | ホスト名ベース（`idp.localhost`, `media.localhost`, `grafana.localhost`）。issuer / redirect URI は overlay で固定。パス prefix は Next.js / OIDC と相性が悪い |

### 追加タイミング

- 単体 Compose が動いてから `deploy/k8s/` を追加してよい（空の kustomization + README から開始可）
- 連携デモに載せる Pxx から順に manifest を埋める（初版: P01, P03, P02 o11y 最小）

