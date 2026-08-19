# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 製品リポジトリのテストを優先する。本表と食い違ったらテストを直すか本表を追随する |

実行: `pf-media/apps/api` で `go test ./...`（単体・HTTP 統合。Compose 起動中は e2e が実 API / Garage を叩く。未起動なら skip）。processor は `apps/processor` で `npm test`。

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-M01 | 他ユーザーのファイル GET | 404 | FR-02 |
| TS-M02 | complete とクォータ | 超過は拒否 | FR-05 |
| TS-M03 | 共有トークン | 所有者以外の一覧に出ない | FR-06 |
| TS-M04 | processor finish | 内部トークン無しは 401 | — |
| TS-M05 | 非画像 | job を切らない | FR-03 |

手動: UI サムネ、OIDC overlay。攻撃手順は書かない。
