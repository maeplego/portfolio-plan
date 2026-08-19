# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 製品リポジトリのテストを優先する。本表と食い違ったらテストを直すか本表を追随する |

実行: `pf-identity/apps/server` で `go test ./...`。Postgres 統合は接続 URL が無いと skip。画面は Playwright（`apps/e2e`）。

攻撃手順や exploit の再現手順は書かない。

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-I01 | health | 200 | — |
| TS-I02 | redirect 不一致 | 拒否 | FR-01 |
| TS-I03 | code 二回交換 | 二回目失敗 | FR-04 |
| TS-I04 | PKCE 不一致 | token 失敗 | FR-02 |
| TS-I05 | refresh 再利用 | family 無効 | FR-05 |
| TS-I06 | logout_token の jti 再利用 | 拒否 | — |
| TS-I07 | e2e ログイン | sample-rp で UserInfo（手動または Playwright） | 受け入れ 1 |

| 要件 | テスト |
| --- | --- |
| FR-01 | TS-I02 |
| FR-02 | TS-I04 |
| FR-04 | TS-I03 |
| FR-05 | TS-I05 |
