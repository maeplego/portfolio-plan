# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | `http://localhost:8014`（Compose。起動の正） |

エラー本文:

```json
{ "error": { "code": "validation_error", "message": "amount must be a safe integer yen" } }
```

開発認証: `X-Dev-User-Sub`（`FINANCE_DEV_AUTH=true`）。OIDC 時は `Authorization: Bearer`。`Content-Type: application/json`。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | store ping |

## ユーザー・ウォレット・カテゴリ

### GET `/v1/me`

200 `{ "id", "sub" }`。

### DELETE `/v1/me`

204。そのユーザーのサーバーデータを消す。

### GET `/v1/wallets`

200 `{ "wallets": [{ "id", "userId", "name" }] }`。初回は「現金」。

### POST `/v1/wallets`

`{ "name": "カード" }` → 201。空名は 400。

### GET `/v1/categories`

200 `{ "categories": [{ "id", "userId", "name", "kind", "updatedAt", "deletedAt" }] }`。初回はデフォルト 5 件。生きている行だけ。

## 取引

### GET `/v1/transactions?month=YYYY-MM`

月欠落は 400。

### GET `/v1/transactions/{id}`

自分の行 200。他人・未知 404。

### POST `/v1/transactions`

```json
{ "categoryId": "...", "occurredOn": "2026-08-10", "amountYen": 1500, "kind": "expense", "memo": "" }
```

PATCH は同じ全項目。`walletId` は省略可（既定ウォレット）。DELETE は 204（tombstone。一覧と GET からは 404）。

### POST `/v1/recurring-rules`

```json
{ "categoryId": "...", "amountYen": 80000, "kind": "expense", "memo": "家賃", "dayOfMonth": 1, "walletId": "任意" }
```

`dayOfMonth` は 1–28。201。

### GET `/v1/recurring-rules`

200 `{ "rules": [...] }`。

### POST `/v1/recurring-rules/{id}/generate`

`{ "month": "2026-08" }`。200 `{ "created": { ... } | null }`。同じ月の再実行は `null`。

### POST `/v1/tombstones/purge`

`{ "before": "2026-08-19T04:00:00.000Z" }`。200 `{ "purged": 1 }`。

### POST `/v1/sync`

認証必須。変更セットを LWW で載せる。1 リクエスト最大 100 件。

```json
{
  "since": "2026-08-20T00:00:00.000Z",
  "changes": [
    {
      "id": "01…",
      "updatedAt": "2026-08-20T04:00:00.000Z",
      "deletedAt": null,
      "walletId": "省略可",
      "categoryId": "…",
      "occurredOn": "2026-08-20",
      "amountYen": 1500,
      "kind": "expense",
      "memo": ""
    }
  ]
}
```

`since` は省略または `null` 可。200:

```json
{
  "applied": ["01…"],
  "rejected": [{ "id": "01…", "reason": "server_newer", "server": { } }],
  "serverChanges": [],
  "cursor": "2026-08-20T04:00:00.000Z"
}
```

`reason` は `server_newer`（新しい方がサーバー。`server` 付き）または `rejected`（他人の id・不正・120 秒超の未来。`server` 無し）。`serverChanges` は `updatedAt > since` の自分の行（tombstone 含む）。クライアントが新しい方が勝つ。同じ時刻はサーバー。削除は `deletedAt` に instant。任意で `categories` と `budgets` 配列も同じ LWW。

### GET `/v1/export.csv?month=YYYY-MM`

`text/csv`。ヘッダ `occurredOn,amountYen,kind,categoryName,memo`。自分のその月だけ。

### POST `/v1/import`

`{ "csv": "..." }`。ヘッダ必須。小数円は 400。カテゴリは名前と kind で突合。201 `{ imported, errors }`。

## 予算とレポート

- `GET /v1/budgets?month=YYYY-MM`
- `PUT /v1/budgets` `{ "month", "limitYen" }`
- `GET /v1/reports/monthly?month=YYYY-MM` — `remainingYen` は予算未設定なら `null`。`byDay` はその月の全日
