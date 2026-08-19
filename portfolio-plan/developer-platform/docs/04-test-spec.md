# P11 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | scanner / CLI の `go test`、portal / ci-dash / review の `go test ./...` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリのテスト。本表と食い違ったらテストを直すか本表を追随 |

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-S01 | testdata/findings | 終了 1、マスク |
| TS-S02 | testdata/clean -offline | 終了 0 |
| TS-S03 | ネットワーク失敗でキャッシュ無し | 終了 2 |
| TS-C01 | new --yes | 生成物 go test |
| TS-P01 | LoadDir(specs) | slug 3 件、payments あり |
| TS-P02 | GET / と /docs/payments | 200、パスと Try it out |
| TS-P03 | POST /mock/payments/v1/charges 正当 | 201 と example id |
| TS-P04 | 同 POST で必須欠落 | 400 |
| TS-P05 | specs の example に秘密形 | テスト失敗（lint） |
| TS-D01 | base vs compatible OpenAPI | specbreak / oasdiff-gate 終了 0 |
| TS-D02 | base vs breaking（フィールド・path 削除） | 終了 1、`response-property-removed` |
| TS-D03 | POST /api/diff breaking | 409 |
| TS-G01 | allowlist 外の repo | 403 |
| TS-G02 | `?path=` | 400 |
| TS-G03 | webhook HMAC 不一致 | 401、secret なしは 404 |
| TS-R01 | コメント HTML | エスケープ |
| TS-R02 | コメント path に `..` | 400 |
| TS-R03 | トークン無し POST comment | 403 |
