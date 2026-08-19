# P14 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P14 personal-finance |
| 対象スライス | 1。自動化は `npm test`（money + api vitest） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリの vitest。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| money | DB なし | 整数円だけ通す |
| report | 純関数 | 予算残りと日次 |
| HTTP | Hono `app.request` + メモリ Store | CRUD、401、隔離、float 400、シード |

exploit / PoC は書かない。実家計を fixture に置かない。

## 2. 金額

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-M01 | 整数 | `parseYen(1200) = 1200` |
| TS-M02 | 12.5 / `"100.0"` / `"1e2"` | YenError |
| TS-M03 | 0 と負の positive 円 | YenError |
| TS-M04 | 符号付き | 収入正・支出負 |

## 3. レポート

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-R01 | 食費 4200+3100、給与 280000、予算 200000 | 支出 7300、残り 192700、6 月 30 日 |

## 4. HTTP

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-H01 | `/health` `/ready` | 認証なし 200 | |
| TS-H02 | `/v1` ヘッダなし | 401 | |
| TS-H03 | alice の取引を bob が list | 空 | FR-02 |
| TS-H04 | bob が alice の id を GET/DELETE | 404 | FR-02 |
| TS-H05 | `amountYen: 12.5` | 400 | FR-01 |
| TS-H06 | 自分の PATCH/DELETE | 200/204 のち list 空 | FR-02 |
| TS-H07 | demo 2026-06 レポート | 支出 97780、収入 280000、残り 102220 | FR-03–05 |
| TS-H08 | other の 2026-06 | 0 | FR-02 |
| TS-H09 | 予算を 150000 に更新 | 残り 52220 | FR-04 |

## 5. 未自動化

- Compose 実機の画面操作と Chrome インストール
- Playwright の Offline 模擬（次スライス）
- Postgres integration タグ
