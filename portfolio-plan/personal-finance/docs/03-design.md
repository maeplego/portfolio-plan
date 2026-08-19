# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 構成

```
apps/web   Next.js PWA。ブラウザから API を直接呼ぶ
apps/api   Hono。認可と永続化の正
packages/money  整数円パーサ
deploy     Compose が主。deploy/k8s は ops overlay 用
```

ローカル DB（Dexie）を正にしない。サーバーが正。Service Worker は installability 用の GET シェルだけ。差分同期プロトコルは未作成。

起動の正は **Compose**（Postgres）。Kubernetes は [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) の ops overlay から参照するマニフェストがある（`finance.localhost` / `finance-api.localhost`、DB 名 `finance`）。このフォルダだけを apply しない。

## 2. 認可

`X-Dev-User-Sub` で `users.sub` を確保する。すべてのクエリは `user_id` 付き。他人の行は NotFound（存在を漏らす 403 にしない）。CSV も同じ隔離。

[pf-identity](https://github.com/maeplego/pf-identity) は未配線。`FINANCE_DEV_AUTH=false` ではヘッダを無視して 401。

## 3. 金額と CSV

`packages/money` が非整数・指数表記を拒否する。Postgres 列は `INTEGER`。レポートは加算のみ。CSV ヘッダは `occurredOn,amountYen,kind,categoryName,memo`。

## 4. レポート

`buildMonthlyReport` は純関数。支出合計、収入合計、差引、予算残り、カテゴリ合計、月の全日の日次。浮動小数の平均は出さない。

## 5. シード

起動時 `seedDemoIfEmpty`。`demo` に取引があれば再投入しない。Compose ボリュームを消すと戻る。
