# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 開発者基盤（GitHub: `pf-developer-cli`、`pf-developer-templates`、`pf-developer-scanner`、`pf-developer-portal`、`pf-developer-ci-dash`、`pf-developer-review`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

開発者が足場を作り、依存をスキャンし、OpenAPI を見てモックし、仕様破壊を CI で止め、公開 Actions と PR を読む、という外から見える振る舞い。

## 1. 目的

新しいサービスの作り方・正しさの見方・壊し方の防ぎ方を一箇所に揃える。学習用。攻撃手順は置かない。横断 Web シェル（未着手の `pf-developer-web`）はまだ無い。

## 2. 含む / 含まない

含む: scanner バイナリ、`pf-dev new` / `scan`、手置き YAML ポータル、example モック、oasdiff ゲート、公開 GitHub Actions のダッシュボード、PR 閲覧 BFF。

含まない: exploit / PoC、GitHub の完全クローン、自動 merge、任意リポジトリ clone、管理画面からの spec アップロード、scanner の Kubernetes 搭載、フレーク検出、自前ランナー。

## 3. scanner と CLI

scanner 終了コード: 0 は指定重大度以上なし、1 は finding あり、2 は使い方ミスまたは OSV 不足でグリーン偽装不可。`-offline` は OSV を飛ばす。

`pf-dev new [-t go-api|go-next]` は非空ディレクトリに `-force` が要る。`--yes` は非対話。`pf-dev scan` は scanner を subprocess。テンプレ根は `PF_DEV_TEMPLATES`、既定は兄弟 `pf-developer-templates`。

## 4. ポータル

ファイルシステムの YAML だけを読む。Git 同期もアップロードも無い。`GET /` はカタログ、`GET /docs/{slug}` は左ナビ付きリファレンスと Try it out。モックは `/mock/{slug}` 配下に spec の paths をマウントする。応答は spec の example。副作用なし（永続化しない）。必須ヘッダ・必須 JSON フィールドが無い、または型が違うと 400 `invalid_request`。マッチしない path/method は 404 `not_found`。YAML は 256KiB 超で読み込み拒否。`POST /api/diff` は JSON の `base` / `revision` YAML だけを比較する（URL fetch なし）。ERR があると 409。

手置き slug: `payments`（架空チャージ）、`commerce-catalog`（EC `pf-commerce` のカタログ子集）、`content-blog`（ブログ `pf-content-blog` の公開投稿子集）。ライブプロキシではない。

## 5. 仕様差分（oasdiff）

PR では `specs/payments-v1.yaml` を base SHA と比較。ローカルは `go run ./cmd/oasdiff-gate base.yaml revision.yaml`（終了 1 = ERR）。フィクスチャ `testdata/openapi/breaking.yaml` はフィールド削除と path 削除。

## 6. CI ダッシュボード

`CI_DASH_REPOS` allowlist の公開 Actions のみ。PAT は任意環境変数。`?path=` は 400。webhook は secret 未設定なら 404、HMAC 不一致は 401。

## 7. レビュー BFF

`REVIEW_REPOS` allowlist。PR 一覧と files/comments を GitHub から読む。コメント POST はトークン必須。ローカル path・`..` を含むファイルアンカーは拒否。

## 8. 受け入れ

1. 古い lock フィクスチャで scanner が終了 1、レポートの秘密がマスク。
2. `pf-dev new --yes` の生成物で `go test` / `npm test` が通る。
3. `GET /docs/payments` にパスと例が出る。モック POST が example を返し、必須欠落は 400。
4. breaking YAML で oasdiff / `oasdiff-gate` が fail。allowlist 外は 403。`?path=` は 400。
