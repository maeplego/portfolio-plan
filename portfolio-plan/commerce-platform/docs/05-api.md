# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | EC コマース（GitHub: `pf-commerce`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

公開 REST の基準 URL は Compose の gateway `http://localhost:8099`。catalog / inventory / order は内部。GraphQL は BFF `http://localhost:8110`。OpenAPI ファイルは未作成。

エラー本文:

```json
{ "error": { "code": "inventory_shortage", "message": "not enough stock" } }
```

不足・決済失敗のチェックアウトは同じオブジェクトに `order` を付ける。

開発認証: `X-Dev-User-Sub`、任意 `X-Dev-Role`（`buyer` \| `ops`）。`Content-Type: application/json`。

## 運用

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` | なし | 200 / 503 | store ping |

## 公開

### GET `/v1/products`

成功 200 `{ "products": [ Product ] }`。

Product:

| 欄 | 型 | 意味 |
| --- | --- | --- |
| id | string | ULID |
| sku | string | 大文字 |
| name | string | |
| description | string | |
| priceMinor | integer | 円 |
| currency | string | JPY |
| imageUrl | string | メディア未接続の URL |
| active | boolean | |
| availableQty | integer | 利用可能 |

### GET `/v1/products/{id}`

成功 200 Product。不正 ULID 400。未知 404。

## 購入者

### GET `/v1/cart`

### POST `/v1/cart/items`

`{ "productId", "qty" }` → 200 Cart。

### PUT `/v1/cart`

`{ "items": [{ "productId", "qty" }] }` で置換。

### POST `/v1/checkout`

ヘッダ `Idempotency-Key` または本文 `idempotencyKey`。`lines` が無ければカート。

成功 201（新規）または 200（再送）:

```json
{
  "id": "...",
  "buyerSub": "alice",
  "status": "paid",
  "cancelReason": "",
  "amountMinor": 1200,
  "currency": "JPY",
  "idempotencyKey": "...",
  "paymentId": "...",
  "lines": [{ "productId": "...", "sku": "MUG-1", "name": "Demo Mug", "qty": 1, "unitPriceMinor": 1200, "currency": "JPY" }],
  "createdAt": "...",
  "updatedAt": "..."
}
```

不足 409:

```json
{
  "order": { "status": "cancelled", "cancelReason": "inventory_shortage" },
  "error": { "code": "inventory_shortage", "message": "not enough stock" }
}
```

空キー・空行 400。未認証 401。

### GET `/v1/orders`

自分の一覧。

### GET `/v1/orders/{id}`

自分または ops。他人の buyer は 403。

### GET `/v1/orders/{id}/events`

イベント列（`OrderCreated`, `InventoryReserved` または `InventoryShortage`, `PaymentRecorded` または `PaymentFailed`, `OrderCancelled`, `OrderShipped`）。認可は GET 注文と同じ。

### POST `/v1/orders/{id}/ship`

`paid` → `shipped`。`pending` / `cancelled` は 409 `invalid_transition`。

### POST `/v1/admin/projections/rebuild`

ops のみ。イベントから `commerce_orders` 投影を作り直す。200 `{ "ok": true }`。

## ops

### POST `/v1/ops/products`

`sku, name, description, priceMinor, currency, imageUrl`。201。重複 SKU 409。buyer は 403。

### GET `/v1/ops/stock`

ops。cursor ページング。`items`: sku, name, qty, reservedQty, availableQty。`nextCursor`。

### GET `/v1/ops/stock/stream`

SSE `event: stock.updated`。認証はヘッダまたは `devUser` / `devRole` クエリ。

### GET `/v1/ops/notifications`

ops。notify のログ。

## GraphQL BFF（`http://localhost:8110`）

`POST /graphql`。下位 REST: catalog products、inventory available、catalog reviews。推薦は `pf-recommend`（任意）。

スキーマ（実装）:

- `Query.products`, `Query.product(id)`, `Query.recommended(userId, k=5)`
- `Product.inventory { availableQty }`, `Product.reviews`, `Product.similar(k=5)`
- `RecommendSlot { source, fallback, products }`

`source` は `"recommend"` または `"popularity"`。推薦失敗時もフィールドは返り、`fallback` は true。
