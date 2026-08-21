# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 構成

```
apps/web   Next.js PWA。ブラウザは同一オリジン /api/finance（BFF）。オフラインキューは IndexedDB。ダークモードは data-theme
apps/api   Hono。認可と永続化
packages/money  整数円パーサ
packages/sync-protocol  decideLww（同時刻はサーバー）
deploy     Compose が起動の正。deploy/k8s は CI／ops overlay 用（単体 apply しない）
```

サーバーが正の一覧・レポートに加え、オフラインの変更セットは `POST /v1/sync` で載せる。各取引は `updatedAt` の新しい方が勝つ（LWW）。同じ時刻はサーバーを残す。削除は `deletedAt` を置く tombstone で、一覧からは消える。新しい `updatedAt` で `deletedAt: null` なら復活する。カテゴリと予算も同じ LWW で載せられる。クライアントの `updatedAt` がサーバー時計より 120 秒以上未来なら `rejected`。

起動の正は **Compose**（Postgres）。Kubernetes マニフェストは禁止ではなく、[pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) の ops overlay から参照する（`finance.localhost` / `finance-api.localhost`、DB 名 `finance`）。このフォルダだけを apply しない。

## 2. 認可

Compose 既定は `X-Dev-User-Sub` で `users.sub` を確保する。`FINANCE_DEV_AUTH=false` ではそのヘッダを無視する。`OIDC_ISSUER` があるときは `Authorization: Bearer` を JWKS または userinfo で検証する（[pf-calendar](https://github.com/maeplego/pf-calendar) と同じ形）。PWA は access token を JS に出さず、Next の httpOnly `rp_access` を BFF が付ける。

すべてのクエリは `user_id` 付き。他人の行は NotFound（存在を漏らす 403 にしない）。CSV も同じ隔離。`DELETE /v1/me` は FK CASCADE（メモリ Store は手動削除）。

CORS 既定は `http://localhost:3014`（直接 API を叩くとき）。PWA は同一オリジンなので CORS を使わない。`*` は明示設定だけ。

## 3. 金額と CSV

`packages/money` が非整数・指数表記を拒否する。Postgres 列は `INTEGER`。レポートは加算のみ。CSV ヘッダは `occurredOn,amountYen,kind,categoryName,memo`。

## 4. レポート

`buildMonthlyReport` は純関数。支出合計、収入合計、差引、予算残り、カテゴリ合計、月の全日の日次。浮動小数の平均は出さない。

## 5. シード

起動時 `seedDemoIfEmpty`。`demo` に生きている取引があれば再投入しない。Compose ボリュームを消すと戻る。

## 6. LWW

比較は `packages/sync-protocol` の `decideLww`。クライアントの `updatedAt` がサーバーより新しいときだけ書く。同じ時刻はサーバーを残す（再送が上書きしない）。他人の id は `rejected` とし、サーバー本文は返さない。

`GET /v1/transactions` とレポートは `deleted_at IS NULL` だけ。HTTP DELETE も tombstone。`POST /v1/tombstones/purge` は `deleted_at < before` を物理削除する。カテゴリと予算は `POST /v1/sync` の `categories` / `budgets` で同じ LWW。クライアントの `updatedAt` が `now + 120s` を超えると拒否する。

## 7. ウォレットと繰り返し

初回アクセスでウォレット「現金」を作る。取引の `walletId` 省略はその既定。繰り返しは `day_of_month` 1–28。`recurring_generations (rule_id, month)` が生成ログ。
