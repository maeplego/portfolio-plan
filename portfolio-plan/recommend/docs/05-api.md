# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン（GitHub: `pf-recommend`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

基準 URL は Compose の推論 `http://localhost:8098`。機械可読は FastAPI `/docs`。学習は CLI のみ。

エラー本文の例:

```json
{ "error": { "code": "not_found", "message": "unknown item_id=..." } }
```

未知 namespace も 404 `not_found`。

## 1. 目的

推論の入力・出力と状態コードを固定する。画面のピクセルは対象外。

## 2. 含む / 含まない

含む: 下表の HTTP。含まない: `/admin/train`、認証必須、カードや個人購買のフィールド。

## 3. エンドポイント

| メソッド | パス | 用途 | 主な状態 |
| --- | --- | --- | --- |
| GET | `/health` | liveness | 200 `{ "ok": true }` |
| GET | `/ready` | モデル有無 | 200 `{ "ok": true, "namespaces": [...] }` / 503 |
| GET | `/v1/recommend?namespace=&user_id=&k=` | ユーザー向け | 200。k 既定 10 最大 50 |
| GET | `/v1/similar-items?namespace=&item_id=&k=` | 類似 | 200 / 404 |
| GET | `/v1/models` | version と Recall@K 等 | 200 `{ "models": [...] }` |
| POST | `/v1/events` | JSONL 追記 | 200 `{ "ok": true }`。オンライン学習しない |

### GET `/v1/recommend` 成功例

```json
{
  "namespace": "commerce",
  "user_id": "brand-new-shopper",
  "model": "popularity",
  "version": "...",
  "fallback": true,
  "items": [{ "item_id": "MUG-1", "score": 0, "title": "", "reason": "" }]
}
```

### GET `/v1/similar-items`

`namespace=commerce&item_id=MUG-1` は SKU 近傍。`namespace=jobs` は求人 id。クエリの item は `items` に含めない。

### POST `/v1/events`

本文 `{ "namespace", "user_id", "item_id", "type", "at?" }`。`type` 既定 `view`。未ロード namespace は 404。

## 4. 受け入れ

パス・クエリ名・ 404/503 がテストと一致する。EC BFF は `items[].item_id` を SKU として読む。
