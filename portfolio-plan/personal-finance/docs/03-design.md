# P14 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P14 personal-finance |
| 対象スライス | 1 |
| 最終更新 | 2026-08-19 |

## 1. 構成

```
apps/web   Next.js。ブラウザから API を直接呼ぶ
apps/api   Hono。認可と永続化の正
packages/money  整数円パーサ（API と単体テスト）
```

スライス 1 ではローカル DB（Dexie）を正にしない。サーバーが正。Service Worker は installability 用の GET シェルだけ。

## 2. 認可

`X-Dev-User-Sub` で `users.sub` を確保する。すべてのクエリは `user_id` 付き。他人の行は NotFound（存在を漏らす 403 にしない）。

P01 は未配線。`FINANCE_DEV_AUTH=false` ではヘッダを無視して 401 になる。

## 3. 金額

`packages/money` が number の非整数、`"100.0"`、指数表記を拒否する。Postgres 列は `INTEGER`。レポート集計は加算のみ（税率などの乗算をしない）。

## 4. レポート

`buildMonthlyReport` は純関数。支出合計、収入合計、差引、予算残り（`limit - expense`）、カテゴリ合計、月の全日の日次。浮動小数の平均は出さない。

## 5. シード

起動時 `seedDemoIfEmpty`。`demo` に取引があれば再投入しない。Compose ボリュームを消すと戻る。

## 6. 同期プロトコル

`packages/sync-protocol` は未作成。updated_at は行に持つが差分同期 API は無い。
