# P01 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | `go test` と Playwright。Postgres 統合は URL が無いと skip |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリのテスト。本表と食い違ったらテストを直すか本表を追随 |

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-I01 | health | 200 |
| TS-I02 | redirect 不一致 | 拒否 |
| TS-I03 | code 二回交換 | 二回目失敗 |
| TS-I04 | PKCE 不一致 | token 失敗 |
| TS-I05 | refresh 再利用 | family 無効 |
| TS-I06 | logout_token jti 再利用 | 拒否 |
| TS-I07 | e2e ログイン | sample-rp UserInfo（手動または Playwright） |

exploit / PoC は書かない。
