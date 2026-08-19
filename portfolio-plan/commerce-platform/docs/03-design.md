# P06 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P06 commerce-platform |
| 対象スライス | スライス 1 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

要件の「何を守るか」に対し、モジュールと永続化で「どう守るか」。スタック選定の短文は `DESIGN.md`。

## 1. 全体構成

```
pf-commerce/
  apps/api          Go。モジュラモノリス
    catalog         商品マスタ
    inventory       移動が正、残高は同トランザクション相当の更新
    cart            購入者の下書き
    payment         モック（カード番号なし）
    order           プロセスマネージャ（引当 → 課金 → 消費 / 補償）
    store/memory    テストと DB なし起動
    store/postgres  Compose
  apps/storefront   Next.js。REST クライアント
  deploy/           Postgres + API + storefront。K8s なし
```

注文確定の正は `apps/api`。storefront は表示とボタンだけ。在庫判定をブラウザに置かない。

モジュール間に FK を張らない。抽出時に DB を分けられるようにテーブル接頭辞だけ共有する。

## 2. なぜまだ 8 サービスにしないか

在庫と注文は将来独立デプロイしたい。それでも最初からプロセスを切ると、不足時の補償と冪等が「ネットワークの話」になり、ドメインが検証できない。スライス 1 は **同一プロセス・同一 DB・明確なパッケージ境界**。次は catalog / inventory / order を別プロセスにし、決済はまだ order 内モックでよい（DESIGN 実装順 2）。

## 3. 引当と同時購入

利用可能 = `qty - reserved_qty`。`TryReserve` は「足りるときだけ reserved を増やす」原子更新。

| 実装 | 原子性 |
| --- | --- |
| Memory | `TryReserve` を mutex 下で実行 |
| Postgres | `UPDATE ... WHERE (qty - reserved_qty) >= $qty RETURNING`。0 行なら shortage |

アプリが先に available を読んでから書くと TOCTOU になる。一覧の `availableQty` はヒントであり、チェックアウトの許可証ではない。

補償: 不足または決済失敗で `ReleaseOrder`（held → released、reserved を戻す）。成功時 `ConsumeOrder`（qty と reserved を同じ数だけ減らす）。

TTL 15 分。期限切れは次の `Reserve` 先頭の `ExpireDue` で回収。専用ワーカーは未実装。

スライス 1 の Postgres は残高 UPDATE と reservation INSERT が別ステートメント。不足レースの正は UPDATE。クラッシュ窓は抽出時に 1 TX へ閉じる。

## 4. 冪等

`(buyer_sub, idempotency_key)` 一意。先に既存を読み、無ければ INSERT。衝突したら既存を返す。決済モックも `pay:` + キーで再課金しない。

## 5. 金額

`money.Amount` は `int64` minor。加算・乗算の overflow を拒否。HTTP は `priceMinor` を `int64` にデコードする。float はデコード失敗 → 400。

## 6. 認可

公開 GET 以外は dev ヘッダ。ops エンドポイントは役割をサーバで見る。注文 GET は `buyer_sub` 一致（ops は例外）。UI の非表示は認可ではない。

## 7. シード

起動時 `MUG-1` 在庫 1、`TEE-1` 20、`STK-1` 0。デモの欠品を最初から混ぜる。
