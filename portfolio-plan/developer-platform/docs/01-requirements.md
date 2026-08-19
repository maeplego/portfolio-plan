# P11 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | 受け入れは scanner と `pf-dev new`。portal は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

内部開発者プラットフォームのミニ版。攻撃手順は置かない。学習用。

含む: OSV 照合、Dockerfile ルール、シークレット検出（マスク）、重大度ゲート、`pf-dev new` が health/ready・OTel env・OIDC stub 付きの実ファイルをコピー、生成物の `go test` / `npm test`。

含まない: exploit/PoC、GitHub 完全クローン、自動 merge、任意 repo clone（SSRF）、portal/CI/review（計画）。

受け入れ: 古い lock フィクスチャで scanner が fail、`pf-dev new --yes demo && go test`、レポートの秘密がマスク。oasdiff 失敗の PR は計画。
