# P11 developer-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/08-code-review-assistant.md`
- `portfolio-idea/15-ci-pipeline-dashboard.md`
- `portfolio-idea/21-repo-security-scanner.md`
- `portfolio-idea/23-cli-project-scaffolding.md`
- `portfolio-idea/29-openapi-developer-portal.md`

テンプレート化する対象（P04 または P06）の DESIGN も、CLI 作業時は渡す。

## 対応アイデア

- 08 コードレビュー支援
- 15 CI パイプライン可視化
- 21 リポジトリ脆弱性診断
- 23 CLI スキャフォールディング
- 29 OpenAPI ドキュメントポータル

## 目的

内部開発者プラットフォーム（Internal Developer Platform）のミニ版。新しいサービスの **作り方・正しさの見方・壊し方の防ぎ方** を一箇所に揃える。5 アイデアは別製品に見えるが、価値は「標準で作 → 仕様がポータルに出る → CI が見える → PR をレビュー → 依存をスキャン」という一本の流れ。

**scanner は MVP（K8s overlay 非搭載）。** CLI は P04 / P06 実ファイルテンプレで完成扱い。portal MVP は overlay B（`portal.localhost`）。oasdiff Action、CI dashboard、review BFF は 2026-08-19 に追加。横断 web シェルは portal ホーム（`PORTAL_*_URL`）で配線済み。

## リポジトリ構成（ポリレポ）

ツールごとに言語とリリース単位が違う（CLI バイナリ vs Web）。ポリレポ。ただし UX の入口は 1 つのポータルにまとめてよい。

| リポジトリ | 役割 | アイデア |
| --- | --- | --- |
| `pf-developer-cli` | プロジェクト生成、`add openapi` 等 | 23。21 の scan をサブコマンドで呼んでも可 |
| `pf-developer-templates` | 生成される雛形（Go API, Next.js, GitHub Actions, OTel, OIDC クライアント） | 23 |
| `pf-developer-scanner` | 脆弱性・シークレット・Dockerfile ルール。単体バイナリ | 21 |
| `pf-developer-portal` | OpenAPI カタログ、モック、diff | 29 |
| `pf-developer-ci-dash` | GitHub Actions の可視化 | 15 |
| `pf-developer-review` | PR diff とコメント（GitHub API） | 08 |
| `pf-developer-web` | 上記へのリンク集、ログイン、チームの「今赤い CI」 | 横断シェル。最初は portal に混ぜてもよい |

`pf-developer-scanner` を CLI のライブラリとして import し、`pf-dev scan` でも `scanner` 単体でも動く、が理想。循環依存を避けるため scanner は独立モジュール。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| CLI / scanner | Go。単一バイナリ、GitHub Releases |
| テンプレート | 実ファイル + `template.json`。生成後に `go test` / `npm test` が通ること |
| Portal / CI / Review | Go + 埋め込み HTML（portal / ci-dash / review）。横断シェルは portal ホーム（step 7 ✅）。独立 `pf-developer-web` は未着手 |
| 脆弱性 DB | OSV API。キャッシュ |
| 仕様差分 | oasdiff Action + `oasdiff-gate` |
| 認証 | 公開 repo はトークンなし可。任意 `GITHUB_TOKEN` は環境変数のみ。暗号化保存と P01 ログインは未着手 |

## 設計思想

- **生成物の品質が CLI の本体。** ツールのプロンプトより、strict TS、`/health`、graceful shutdown、OTel。CLI は P04/P06 実体ベース。scanner は MVP のまま。portal は手置き YAML の HTML リファレンスと example モック。仕様差分は oasdiff Action（fixture + PR の `specs/`）と `cmd/oasdiff-gate`。CI dash / review は公開 repo の GitHub API 読み取り（書き込みコメントは任意トークン）。
- **攻撃ではなく修正。** スキャナーに exploit / PoC を置かない
- **仕様を CI ゲートにする。** ポータルの見た目より breaking change で fail する Action
- **GitHub を再実装しすぎない。** Review は GitHub API を BFF。自前 git 実行はパストラバーサルが怖いので避ける

## 実装順序（プロジェクト内）

1. ✅ **scanner MVP**（`../pf-developer-scanner`）。Go.mod / npm lock + OSV、Dockerfile ルール、シークレット検出（マスク）、Markdown、重大度ゲート。exploit / PoC なし。2026-08-19
2. ✅ **portal MVP**（`../pf-developer-portal`）。手置き OpenAPI（payments / P06 catalog 子集 / P08 posts 子集）をカタログとリファレンスで表示。`/mock/{slug}` は example 優先、スキーマ検証で 400。管理アップロードは未着手。2026-08-19
3. ✅ **CLI + templates**（`../pf-developer-cli`, `../pf-developer-templates`）。`pf-dev new` が P04 workspace / P06 commerce の実ファイル（health/ready、OTel env、OIDC stub、catalog、httptest）をコピーする。生成物は `go test` / `npm test`。scanner は subprocess。テンプレに oasdiff workflow を同梱。2026-08-19
4. ✅ **openapi-diff Action**（`pf-developer-portal/.github/workflows/openapi-breaking.yml` + `testdata/openapi` + `cmd/oasdiff-gate`）。upstream `oasdiff/oasdiff-action` が breaking fixture で fail、compatible で green。2026-08-19
5. ✅ **CI dashboard**（`../pf-developer-ci-dash`）。公開 Actions の allowlist 読み取り。任意 HMAC webhook。PAT は git に置かない。2026-08-19
6. ✅ **code review UI**（`../pf-developer-review`）。GitHub API BFF。ローカル path 拒否。巨大 diff は切り詰め。2026-08-19
7. ✅ **web シェル** — portal ホームから CI dash / review / scanner へ（`PORTAL_*_URL` env）

## 実装上の注意点

- テンプレートの postInstall で任意シェルを無限に実行しない
- PAT をログに出さない。公開デモは公開リポジトリ + 読み取り専用
- スキャナーは検出シークレットをマスク
- ポータルに載せる example から本番秘密を lint で落とす
- 自前 CI ランナーで信頼できないコードを回さない（アイデア 15 の発展はローカル限定と明記）
- 巨大 PR の DOM 爆発を避ける

## 他プロジェクトとの契約

テンプレートが最初から守ること:

- P01 クライアント設定のコメント
- OTLP 環境変数（P02）
- OpenAPI 出力（P29）
- Dockerfile 非 root（P17 の精神）

P08 / P06 の spec をポータルに登録する。

## デモ

- `pf-dev new --yes demo && cd demo && go test ./...`（または `compose up`）で health が 200
- 古い lock のフィクスチャで scanner が fail
- フィールド削除の PR で oasdiff が fail
- Actions の赤がダッシュボードに出る

## 非目標

- GitHub の完全クローン
- 自動 merge ボット
- 公開マルチテナント SaaS としての任意 repo clone（SSRF）
