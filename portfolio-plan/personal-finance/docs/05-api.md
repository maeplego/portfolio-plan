# P14 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P14 personal-finance |
| 対象スライス | スライス 1 の HTTP。OpenAPI は未作成 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8014`（Compose） |

エラー本文:

```json
{ "error": { "code": "validation_error", "message": "amount must be a safe integer yen" } }
```

開発認証: `X-Dev-User-Sub`。`Content-Type: application/json`。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | store ping |

## ユーザー

### GET `/v1/me`

200 `{ "id", "sub" }`。

### GET `/v1/categories`

200 `{ "categories": [{ "id", "userId", "name", "kind" }] }`。初回はデフォルト 5 件を作る。

## 取引

### GET `/v1/transactions?month=YYYY-MM`

200 `{ "transactions": [ Transaction ] }`。月欠落は 400。

### GET `/v1/transactions/{id}`

自分の行 200。他人・未知 404。

### POST `/v1/transactions`

```json
{ "categoryId": "...", "occurredOn": "2026-08-10", "amountYen": 1500, "kind": "expense", "memo": "" }
```

201 Transaction。`amountYen` は正の整数のみ。カテゴリの kind と不一致は 400。

### PATCH `/v1/transactions/{id}`

本文は POST と同じ全項目。200。

### DELETE `/v1/transactions/{id}`

204。ハードデリート。

### GET `/v1/export.csv?month=YYYY-MM`

`text/csv`。ヘッダ `occurredOn,amountYen,kind,categoryName,memo`。自分のその月だけ。

### POST `/v1/import`

`{ "csv": "..." }`。ヘッダ必須。小数円は 400。カテゴリは名前と kind で突合。201 `{ imported, errors }`。

Transaction:

| 欄 | 型 | 意味 |
| --- | --- | --- |
| id | string | ULID |
| categoryId | string | |
| occurredOn | string | YYYY-MM-DD |
| amountYen | integer | 正の円 |
| kind | string | expense \| income |
| memo | string | |
| createdAt / updatedAt | string | ISO timestamptz |

## 予算とレポート

### GET `/v1/budgets?month=YYYY-MM`

200 `{ "budget": Budget \| null }`。

### PUT `/v1/budgets`

`{ "month", "limitYen" }` → 200 Budget。`limitYen` は正の整数円。

### GET `/v1/reports/monthly?month=YYYY-MM`

200:

```json
{
  "month": "2026-06",
  "incomeYen": 280000,
  "expenseYen": 97780,
  "netYen": 182220,
  "budgetLimitYen": 200000,
  "remainingYen": 102220,
  "byCategory": [{ "categoryId": "...", "name": "住居", "kind": "expense", "amountYen": 80000 }],
  "byDay": [{ "date": "2026-06-01", "expenseYen": 80000, "incomeYen": 0 }]
}
```

`remainingYen` は予算未設定なら `null`。`byDay` はその月の全日。
