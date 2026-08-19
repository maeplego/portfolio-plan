# P11 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | CLI と portal HTTP。oasdiff / admin は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | portal `http://localhost:8111`（Compose / `go run`） |

## コマンド

```
scanner scan [-offline] [-min-severity] [-o report.md] <root>
pf-dev new [-t go-api|go-next] [--module] [--yes] [-force] [-o] <name>
pf-dev create [-o] api|next <name>
pf-dev scan [-offline] <root>
```

## Portal HTTP

機械可読 OpenAPI は各 slug の手置き YAML（`GET /api/specs/{slug}`）。モックは副作用なし。

| メソッド | パス | 成功 | 説明 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | 200 `{ "ok": true }` | プローブ |
| GET | `/` | 200 HTML | カタログ |
| GET | `/docs/{slug}` | 200 HTML / 404 | リファレンス |
| GET | `/api/catalog` | 200 `{ "apis": [...] }` | 一覧 |
| GET | `/api/specs/{slug}` | 200 YAML / 404 | 生 spec |
| * | `/mock/{slug}/{path}` | spec どおり | example または 400/404 |

モックエラー本文:

```json
{ "error": { "code": "invalid_request", "message": "amountMinor is required" } }
```

計画: `POST /admin/specs`、`POST /cli/diff`。受け入れに入れない。
