# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン（GitHub: `pf-recommend`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 製品リポジトリの `pytest` を優先する。本表と違うときはテストか本表のどちらかを直す |

自動化はリポジトリ根で `python -m pytest`。実顧客ログは fixture にしない。

## 1. 目的

時間リーク、コールドスタート、未知 item、EC SKU 契約、空 registry の `/ready` を回帰する。

## 2. 含む / 含まない

含む: API httptest、学習パイプラインの tiny データ、commerce / jobs の similar 契約。

含まない: ランダム split の完成、Compose 実機の負荷、BFF fail-closed（それは `pf-commerce` の Node テスト）。

## 3. ケース

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-R01 | 時間 split | 未来が学習に入らない |
| TS-R02 | 未知ユーザー（movies / commerce） | `fallback: true`、人気、200 |
| TS-R03 | similar 未知 id | 404 `not_found` |
| TS-R04 | `/ready` 空 | 503 |
| TS-R05 | 既知ユーザー recommend | `fallback: false`、items あり |
| TS-R06 | `namespace=jobs` similar | 近傍 id。クエリ自身は含めない |
| TS-R07 | `namespace=commerce` similar `MUG-1` | `TEE-1` 等。`MUG-1` は含めない |
| TS-R08 | `/v1/models` | movies / jobs / commerce が揃う |
| TS-R09 | ランダム split | 未実装。完成条件にしない |

## 4. 受け入れ

1. CI の pytest が上表の実装済み ID で緑。
2. Git に巨大 npy や実購買 CSV が無い。
