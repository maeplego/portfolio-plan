# P11 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | 両リポジトリ `go test` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリのテスト。本表と食い違ったらテストを直すか本表を追随 |

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-S01 | testdata/findings | 終了 1、マスク |
| TS-S02 | testdata/clean -offline | 終了 0 |
| TS-S03 | ネットワーク失敗でキャッシュ無し | 終了 2 |
| TS-C01 | new --yes | 生成物 go test |
