# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | 開発者基盤（CLI [pf-developer-cli](https://github.com/maeplego/pf-developer-cli)、テンプレート [pf-developer-templates](https://github.com/maeplego/pf-developer-templates)、scanner [pf-developer-scanner](https://github.com/maeplego/pf-developer-scanner)、ポータル [pf-developer-portal](https://github.com/maeplego/pf-developer-portal)、CI ダッシュ [pf-developer-ci-dash](https://github.com/maeplego/pf-developer-ci-dash)、レビュー [pf-developer-review](https://github.com/maeplego/pf-developer-review)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

内部開発者プラットフォームのミニ版。新しいサービスの **作り方・正しさの見方・壊し方の防ぎ方** を一箇所に揃える。価値は「標準で作る → 仕様がポータルに出る → CI が見える → PR を読む → 依存をスキャン」という一本の流れである。学習用であり、攻撃手順は置かない。

## 2. 含む

- scanner: OSV 照合、Dockerfile ルール、シークレット検出（マスク）、重大度ゲート
- `pf-dev new` が health/ready・OTel env・OIDC stub 付きの実ファイルをコピー（ワークスペース / EC 由来）
- 生成物の `go test` / `npm test`。`pf-dev scan` は scanner を subprocess
- 手置き OpenAPI のカタログ、リファレンス、example モック
- breaking OpenAPI で fail する oasdiff Action と `oasdiff-gate`
- 公開 GitHub Actions の読み取りダッシュボード（allowlist）
- GitHub API 経由の PR diff / コメント（BFF）
- overlay B の `portal.localhost`

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| exploit / PoC | 攻撃ではなく修正 |
| GitHub の完全クローン、自動 merge | 範囲外 |
| 任意リポジトリ clone | SSRF |
| 管理画面からの spec アップロード | 手置き YAML のみ |
| ローカル git パスのレビュー | パストラバーサル |
| scanner の Kubernetes overlay | 単体バイナリ |
| 横断 Web シェル（`pf-developer-web`） | 未着手。portal / dash / review は別ポート |
| PostgreSQL 履歴 | 未実装 |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| 内部開発者 | 足場を作り、仕様と CI を見る | 公開 repo はトークンなし可 |
| CI | oasdiff ゲート | GitHub Actions |
| レビュア | PR diff を読む | 任意 `GITHUB_TOKEN`（環境変数のみ） |

## 5. 前提

- テンプレート根は `PF_DEV_TEMPLATES`、既定は兄弟 `pf-developer-templates`
- PAT を Git に置かない。ログに出さない
- ポータルはファイルシステムの YAML だけを読む。URL fetch なし
- 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) のログインは未配線

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 古い lock フィクスチャで scanner が fail する（終了 1）。OSV 不足でグリーン偽装しない（終了 2） | ゲート |
| FR-02 | 検出した秘密はレポートでマスクする | 二次漏洩 |
| FR-03 | `pf-dev new --yes` が実ファイルを出し、生成物のテストが通る | CLI の本体は生成物の品質 |
| FR-04 | `GET /docs/{slug}` にパスと例が出る | 手置き仕様の可読性 |
| FR-05 | モック POST は example を返し、必須欠落は 400 | 契約の試運転 |
| FR-06 | `testdata/openapi/breaking.yaml` で oasdiff / `oasdiff-gate` が fail する | 仕様破壊を CI で止める |
| FR-07 | CI dash は allowlist 外の repo を 403、`?path=` は 400 | 読み取り範囲 |
| FR-08 | review BFF はローカル path を拒否し、巨大 diff は切り詰める | パストラバーサルと DOM 爆発 |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | scanner に exploit / PoC を置かない | 安全 |
| NFR-02 | テンプレートの postInstall で任意シェルを無限に実行しない | 供給連鎖 |
| NFR-03 | ポータル example から本番秘密を落とす | lint |
| NFR-04 | README に学習用である旨を書く | 誤用 |

## 8. 受け入れ

1. 古い lock フィクスチャで scanner が fail し、レポートの秘密がマスクされる
2. `pf-dev new --yes demo` のあと生成物の `go test` または `npm test` が通る
3. `GET /docs/payments` にパスと例が出る。モック POST が example を返し必須欠落は 400
4. breaking fixture で oasdiff ゲートが fail する
5. allowlist 外は 403、`?path=` は 400
6. ローカル path のレビュー要求は拒否される
