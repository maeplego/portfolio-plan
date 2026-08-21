# P06 commerce-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-commerce`（1 git・`apps/` プロセス分割） |
| 設計 | [commerce-platform/DESIGN.md](../commerce-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P06** |
| 元アイデア | 05 EC MS、06 在庫ダッシュ、24 GraphQL BFF、25 ES 注文 |
| 役割 | D2C 注文〜出荷のマイクロサービス。ポートフォリオ BE 本線 |
| 構成 | catalog / inventory / order / payment / notify / gateway / bff / storefront / ops-web + Postgres 多 DB |

メッセージは **RabbitMQ 未導入**（outbox ポーリング。DESIGN 明記）。

---

## 2. 目的・スコープ

在庫と注文を別ライフサイクルで分ける。購入者は GraphQL BFF、倉庫は REST+SSE。注文はイベント append＋投影。

**含む:** カート、checkout 冪等、在庫引当／不足補償、決済モック、通知ログ、注文タイムライン、ops グリッド+SSE、BFF DataLoader、P07 fail-closed、OIDC+org、購入イベント POST（任意）。

---

## 3. 実装済み機能

### 3.1 gateway（`:8099`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/v1/products*` | カタログ＋可用数 |
| GET/POST/PUT | `/v1/cart*` | カート |
| POST | `/v1/checkout` | Idempotency-Key。任意で P07 events |
| GET | `/v1/orders*` | 代理 |
| POST | `/v1/orders/{id}/ship` | 出荷 |
| GET | `/v1/ops/stock`、`.../stream`（SSE）、notifications | ops |

内部: catalog／inventory／order／payment／notify。order に **`GET /v1/ops/exports/orders`**（gateway 未露出・P13 向け直叩き）。

### 3.2 GraphQL BFF（`:8110`）／UI

`products`／`product`／`recommended`、inventory／reviews／similar。storefront `:3009`（`/demo` 競合）、ops `:3010`。

### 3.3 無いもの

マーケットプレイス、本格決済／PCI、Kafka、Yoga/Apollo、gateway 経由 exports。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 開発 | `COMMERCE_DEV_AUTH` + `X-Dev-User-Sub`／Role／Org |
| OIDC | storefront → BFF が upstream へ伝播 |
| 公開カタログ | 認証なし |

`org_id` を cart／orders／products にスタンプ（RLS なし・アプリ層）。

---

## 5. デモ起動

```powershell
cd deploy
copy .env.example .env
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3009 | storefront／`/demo` |
| http://localhost:3010 | ops |
| http://localhost:8099/health | gateway |

レビューパック: `review-up.ps1 -Pack p06`。K8s overlay D。

---

## 6. 他 Pxx との契約

- **P01:** 購入者／ops。OIDC 時 `org`。
- **P03:** 画像 URL／seed（任意）。
- **P07:** similar／recommend fail-closed。events 任意。
- **P13:** order exports（gateway 非 proxy）。
- **P12:** 在庫停止シナリオ可（本番コマンドは叩かない）。

---

## 7. 非目標

本番 EC 置き換え、マーケットプレイス、本物カード、Kafka クラスタ。

---

## 8. テスト

リポ根 `go test ./...`、BFF `npm test`、storefront Playwright（CI 外）、`compose-smoke.mjs`。OpenAPI なし。

---

## 9. ギャップ／注意点

| # | 内容 |
| --- | --- |
| 1 | RabbitMQ 未導入は意図的（DESIGN） |
| 2 | exports が gateway 非公開 |
| 3 | 単体 Compose に P07 無し → popularity フォールバック |
| 4 | pf-commerce に AGENTS.md 無し（project 側のみ） |

---

## 10. 根拠パス

- `portfolio-plan/commerce-platform/DESIGN.md`、`docs/05-api.md`、`commerce-platform/AGENTS.md`
- `pf-commerce/apps/{api,catalog,inventory,order,payment,notify,bff,storefront,ops-web}`
- `pf-cloud-k8s` pack `p06`、overlay D
