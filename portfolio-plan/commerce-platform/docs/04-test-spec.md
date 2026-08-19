# P06 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | 2。自動化はリポジトリルートの `go test ./...` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリの Go テスト。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| money | DB なし | 負数・通貨・overflow |
| inventory / order | メモリ Store + 固定 Clock | 不足、補償、TTL、同時引当 |
| HTTP | httptest。gateway は catalog/inventory/order を別サーバとして接続 | 公開契約、401/403、冪等 200、float 価格、同時 409 |

exploit / PoC は書かない。カード番号を fixture に置かない。

メモリの同時 checkout は inventory の mutex 下 `ReserveHeld`（Postgres では 1 TX の UPDATE）と同じ**契約**。gateway の TS-H06 はプロセス間 HTTP でも 201 と 409 が 1 ずつ。

## 2. 金額

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-M01 | 負の minor | エラー |
| TS-M02 | 通貨 3 文字以外 | エラー |
| TS-M03 | 数量乗算 | 1200×3=3600 JPY |
| TS-M04 | 通貨不一致の加算 | エラー |
| TS-M05 | overflow | エラー |

## 3. 在庫

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-I01 | 入庫 5 → 引当 3 | available 2 |
| TS-I02 | 残り 2 に 3 | shortage。available は 2 のまま |
| TS-I03 | 引当解除 | available が戻る |
| TS-I04 | 消費 | on-hand 0。次の引当は shortage |
| TS-I05 | 同時 2 引当（在庫 1） | 成功 1 / shortage 1 |
| TS-I06 | TTL 超過 + ExpireDue | available 復元 |

## 4. 注文（プロセスマネージャ）

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-C01 | 在庫 5 を 1 点 | paid。available 4 | FR-05 |
| TS-C02 | 在庫 1 を 2 点 | cancelled + shortage。available 1 | FR-04 |
| TS-C03 | 同時 2 人・在庫 1 | paid 1 と shortage 1。available 0 | FR-03 |
| TS-C04 | 同一冪等キー | 同じ order id。追加減算なし | FR-02 |
| TS-C05 | 決済モック失敗 | cancelled + payment_failed。在庫復元 | FR-06 |
| TS-C06 | カート経由 | 金額 qty×単価。カート空 | |
| TS-C07 | 他人の注文 | forbidden | FR-07 |

## 5. HTTP

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-H01 | `/health` `/ready` | 認証なし 200 |
| TS-H02 | 公開一覧 | MUG-1 在庫 1。負の価格なし |
| TS-H03 | チェックアウト 401 | ヘッダなし |
| TS-H04 | 成功 + 冪等再送 | 201 のち 200、同一 id |
| TS-H05 | 数量 2 の不足 | 409 `inventory_shortage`。在庫 1 のまま |
| TS-H06 | 同時 HTTP | 201 と 409 が 1 ずつ |
| TS-H07 | 購入者の入庫 | 403 |
| TS-H08 | `priceMinor: 12.5` | 400 |
| TS-H09 | 他人の GET order | 403 |

## 6. 未自動化

- Compose 実機の `/demo` 同時クリック（契約は TS-H06）
- overlay D 実機は `cluster-smoke-d-commerce.ps1`（手動・Docker Desktop）
- Postgres 並列 UPDATE の integration タグ
- 予約 TTL ワーカー
