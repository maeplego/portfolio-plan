# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | 自動化は `npm test`（`packages/money`、`apps/api`、`apps/web` のキュー純関数）。この表と食い違ったらテストかこの文書を直す |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| money | DB なし | 整数円だけ通す |
| report | 純関数 | 予算残りと日次 |
| HTTP | Hono `app.request` + メモリ Store | CRUD、401、隔離、float 400、シード、CSV |
| Playwright | `apps/web` の `test:e2e`。メモリ API。既定 CI では動かない | 2026-08 サマリーと other 隔離 |
| offline queue | `apps/web/lib/offline-queue.test.ts` | オフライン表示、ネットワーク失敗で残す、400 は捨てる |

実家計を fixture に置かない。

## 2. 金額とレポート

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-M01 | 整数 | `parseYen(1200) = 1200` |
| TS-M02 | 12.5 / `"100.0"` / `"1e2"` | YenError |
| TS-M03 | 0 と負 | YenError |
| TS-R01 | 食費と給与と予算 | 整数の合計と残り、月の日数 |

## 3. HTTP

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-H01 | `/health` `/ready` | 認証なし 200 |
| TS-H02 | `/v1` ヘッダなし | 401 |
| TS-H03 | alice の取引を bob が list | 空 |
| TS-H04 | bob が alice の id を GET/DELETE | 404 |
| TS-H05 | `amountYen: 12.5` | 400 |
| TS-H06 | 自分の PATCH/DELETE | 200/204 のち list 空 |
| TS-H07 | demo 2026-06 レポート | 支出 97780、収入 280000、残り 102220 |
| TS-H08 | other の 2026-06 | 0 |
| TS-H09 | 予算更新 | 残りが変わる |
| TS-H10 | export 後に他ユーザーへ import | 件数は増える。元 id は混ざらない |
| TS-H11 | import の小数円 | 400 |
| TS-H12 | CORS | PWA オリジンは ACAO。他 Origin は `*` を付けない |

## 4. 未自動化

- Compose 実機の画面操作と Chrome インストール（Playwright の今月サマリーはメモリ API で自動化。DevTools Offline のブラウザ確認は未実施）
- Postgres integration タグ
- Kubernetes overlay の apply（マニフェストは存在する）
