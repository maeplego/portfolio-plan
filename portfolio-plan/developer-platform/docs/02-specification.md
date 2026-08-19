# P11 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | CLI、scanner、portal HTTP（手置き spec） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

scanner 終了コード: 0 は指定重大度以上なし、1 は finding あり、2 は使い方ミスまたは OSV 不足でグリーン偽装不可。`-offline` は OSV を飛ばす。

`pf-dev new [-t go-api|go-next]` は非空ディレクトリに `-force` が要る。`--yes` は非対話。`pf-dev scan` は scanner を subprocess。テンプレ根は `PF_DEV_TEMPLATES`、既定は兄弟 `pf-developer-templates`。

ポータルはファイルシステムの YAML だけを読む。Git 同期もアップロードも無い。`GET /` はカタログ、`GET /docs/{slug}` は左ナビ付きリファレンスと Try it out。モックは `/mock/{slug}` 配下に spec の paths をマウントする。応答は spec の example。副作用なし（永続化しない）。必須ヘッダ・必須 JSON フィールドが無い、または型が違うと 400 `invalid_request`。マッチしない path/method は 404 `not_found`。YAML は 256KiB 超で読み込み拒否。

手置き slug: `payments`（架空チャージ）、`commerce-catalog`（P06 子集）、`content-blog`（P08 公開投稿子集）。ライブプロキシではない。
