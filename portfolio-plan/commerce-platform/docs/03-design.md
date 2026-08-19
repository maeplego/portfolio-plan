# P06 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | スライス 2 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

要件の「何を守るか」に対し、プロセスと永続化で「どう守るか」。スタック選定の短文は `DESIGN.md`。

## 1. 全体構成

```
pf-commerce/                    1 git リポジトリ（8 リポジトリにはしない）
  packages/                     薄い共有（money, id, clock, auth, httpjson）
  apps/catalog                  商品マスタ HTTP。DB `catalog`
  apps/inventory                在庫 HTTP。DB `inventory`
  apps/order                    チェックアウト。決済モックはここ。DB `orders`
  apps/api                      公開 gateway。カート。DB `gateway`
  apps/storefront               Next.js。REST クライアントは :8099 のみ
  deploy/                       Compose。K8s / overlay D なし
```

注文確定の正は `apps/order`。gateway は公開契約とカート。在庫判定をブラウザに置かない。プロセス間に FK を張らない。

## 2. なぜ 8 リポジトリにしないか

在庫と注文は独立デプロイしたい。ポリレポ 8 本は配線と版合わせが先に壊れる。スライス 2 は **同一リポジトリ・別プロセス・別 DB**。決済はまだ order 内モック。overlay D は Compose の購入〜不足が安定してから。

## 3. 引当と同時購入

利用可能 = `qty - reserved_qty`。`ReserveHeld` は残高 UPDATE・reservation INSERT・movement INSERT を 1 トランザクション。足りないときは shortage でロールバック。

| 実装 | 原子性 |
| --- | --- |
| Memory | `ReserveHeld` を mutex 下で実行 |
| Postgres | 上記 3 文を 1 TX。UPDATE 0 行なら shortage |

アプリが先に available を読んでから書くと TOCTOU になる。一覧の `availableQty` はヒントであり、チェックアウトの許可証ではない。

補償: 不足または決済失敗で `ReleaseOrder`。成功時 `ConsumeOrder`。

TTL 15 分。期限切れは次の `Reserve` 先頭の `ExpireDue` で回収。

order は inventory を HTTP で呼ぶ。同期の短いコマンド。2PC は使わない。

## 4. 冪等

`(buyer_sub, idempotency_key)` は order DB で一意。gateway はカートを行に展開してから order に渡す。決済モックも `pay:` + キーで再課金しない。カード番号フィールドなし。

## 5. 金額

`money.Amount` は `int64` minor。HTTP は `priceMinor` を `int64` にデコードする。float は 400。

## 6. 認可

公開 GET 以外は gateway の dev ヘッダ。ops は gateway で役割を見る。注文 GET は order が `buyer_sub` 一致を見る。catalog / inventory のポートは Compose 内のみ公開しない。

## 7. シード

catalog が 3 SKU を作る。inventory は catalog 一覧を待って `MUG-1` 在庫 1、`TEE-1` 20、`STK-1` 0。
