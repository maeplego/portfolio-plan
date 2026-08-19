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

開発認証: `X-Dev-User-Sub`。`Content-Type: application/json`。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | store ping |

## ユーザーとカテゴリ

### GET `/v1/me`

200 `{ "id", "sub" }`。

### GET `/v1/categories`

200 `{ "categories": [{ "id", "userId", "name", "kind" }] }`。初回はデフォルト 5 件。

## 取引

### GET `/v1/transactions?month=YYYY-MM`

月欠落は 400。

### GET `/v1/transactions/{id}`

自分の行 200。他人・未知 404。

### POST `/v1/transactions`

```json
{ "categoryId": "...", "occurredOn": "2026-08-10", "amountYen": 1500, "kind": "expense", "memo": "" }
```

PATCH は同じ全項目。DELETE は 204（tombstone。一覧と GET からは 404）。

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

`reason` は `server_newer`（新しい方がサーバー。`server` 付き）または `rejected`（他人の id・不正。`server` 無し）。`serverChanges` は `updatedAt > since` の自分の行（tombstone 含む）。クライアントが新しい方が勝つ。同じ時刻はサーバー。削除は `deletedAt` に instant。

### GET `/v1/export.csv?month=YYYY-MM`

`text/csv`。ヘッダ `occurredOn,amountYen,kind,categoryName,memo`。自分のその月だけ。

### POST `/v1/import`

`{ "csv": "..." }`。ヘッダ必須。小数円は 400。カテゴリは名前と kind で突合。201 `{ imported, errors }`。

## 予算とレポート

- `GET /v1/budgets?month=YYYY-MM`
- `PUT /v1/budgets` `{ "month", "limitYen" }`
- `GET /v1/reports/monthly?month=YYYY-MM` — `remainingYen` は予算未設定なら `null`。`byDay` はその月の全日
