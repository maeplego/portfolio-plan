# P11 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | 受け入れは scanner、`pf-dev new`、portal のカタログ/リファレンス/モック、oasdiff ゲート、公開 CI dash、review BFF |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

内部開発者プラットフォームのミニ版。攻撃手順は置かない。学習用。

含む: OSV 照合、Dockerfile ルール、シークレット検出（マスク）、重大度ゲート、`pf-dev new` が health/ready・OTel env・OIDC stub 付きの実ファイルをコピー、生成物の `go test` / `npm test`、手置き OpenAPI の見やすいリファレンスと example モック、breaking OpenAPI で fail する oasdiff Action（fixture）、公開 GitHub Actions の読み取りダッシュボード、GitHub API 経由の PR diff / コメント。

含まない: exploit/PoC、GitHub 完全クローン、自動 merge、任意 repo clone（SSRF）、管理画面からの spec アップロード、ローカル git パスのレビュー、scanner の K8s overlay、横断 web シェル、PostgreSQL 履歴（計画）。

受け入れ: 古い lock フィクスチャで scanner が fail、`pf-dev new --yes demo && go test`、レポートの秘密がマスク、`GET /docs/payments` にパスと例が出る、モック POST が example を返し必須欠落は 400、`testdata/openapi/breaking.yaml` で oasdiff / `oasdiff-gate` が fail、allowlist 外の repo は 403、`?path=` は 400。
