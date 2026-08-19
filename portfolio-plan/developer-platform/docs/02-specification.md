# P11 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | CLI、scanner、portal HTTP、oasdiff ゲート、CI dash、review BFF |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

scanner 終了コード: 0 は指定重大度以上なし、1 は finding あり、2 は使い方ミスまたは OSV 不足でグリーン偽装不可。`-offline` は OSV を飛ばす。

`pf-dev new [-t go-api|go-next]` は非空ディレクトリに `-force` が要る。`--yes` は非対話。`pf-dev scan` は scanner を subprocess。テンプレ根は `PF_DEV_TEMPLATES`、既定は兄弟 `pf-developer-templates`。

ポータルはファイルシステムの YAML だけを読む。Git 同期もアップロードも無い。`GET /` はカタログ、`GET /docs/{slug}` は左ナビ付きリファレンスと Try it out。モックは `/mock/{slug}` 配下に spec の paths をマウントする。応答は spec の example。副作用なし（永続化しない）。必須ヘッダ・必須 JSON フィールドが無い、または型が違うと 400 `invalid_request`。マッチしない path/method は 404 `not_found`。YAML は 256KiB 超で読み込み拒否。`POST /api/diff` は JSON の `base` / `revision` YAML だけを比較する（URL fetch なし）。ERR があると 409。

手置き slug: `payments`（架空チャージ）、`commerce-catalog`（P06 子集）、`content-blog`（P08 公開投稿子集）。ライブプロキシではない。

oasdiff: PR では `specs/payments-v1.yaml` を base SHA と比較。ローカルは `go run ./cmd/oasdiff-gate base.yaml revision.yaml`（終了 1 = ERR）。フィクスチャ `testdata/openapi/breaking.yaml` はフィールド削除と path 削除。

CI dash: `CI_DASH_REPOS` allowlist の公開 Actions のみ。PAT は任意環境変数。`?path=` は 400。webhook は secret 未設定なら 404、HMAC 不一致は 401。

review: `REVIEW_REPOS` allowlist。PR 一覧と files/comments を GitHub から読む。コメント POST はトークン必須。ローカル path・`..` を含むファイルアンカーは拒否。
