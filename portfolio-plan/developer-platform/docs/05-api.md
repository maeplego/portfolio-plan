# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 開発者基盤（GitHub: `pf-developer-cli`、`pf-developer-portal`、`pf-developer-ci-dash`、`pf-developer-review`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

基準: portal `http://localhost:8111`、ci-dash `:8115`、review `:8118`。管理アップロードは計画であり、受け入れに入れない。

## コマンド

```
scanner scan [-offline] [-min-severity] [-o report.md] <root>
pf-dev new [-t go-api|go-next] [--module] [--yes] [-force] [-o] <name>
pf-dev create [-o] api|next <name>
pf-dev scan [-offline] <root>
oasdiff-gate [-fail-on ERR] <base.yaml> <revision.yaml>
```

`oasdiff-gate` 終了 0 = ERR なし、1 = breaking、2 = 使い方 / サイズ。

## Portal HTTP

機械可読 OpenAPI は各 slug の手置き YAML（`GET /api/specs/{slug}`）。モックは副作用なし。

| メソッド | パス | 成功 | 説明 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | 200 `{ "ok": true }` | プローブ |
| GET | `/` | 200 HTML | カタログ |
| GET | `/docs/{slug}` | 200 HTML / 404 | リファレンス |
| GET | `/api/catalog` | 200 `{ "apis": [...] }` | 一覧 |
| GET | `/api/specs/{slug}` | 200 YAML / 404 | 生 spec |
| POST | `/api/diff` | 200 または 409 | `{ "base", "revision" }` YAML。URL は受け取らない |
| * | `/mock/{slug}/{path}` | spec どおり | example または 400/404 |

モックエラー本文:

```json
{ "error": { "code": "invalid_request", "message": "amountMinor is required" } }
```

## CI dash HTTP（`:8115`）

| メソッド | パス | 成功 | 説明 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | 200 | プローブ |
| GET | `/` | 200 HTML | allowlist。`?repo=owner/name` はリダイレクト。`?path=` は 400 |
| GET | `/repos/{owner}/{repo}` | 200 / 403 | 実行一覧 HTML |
| GET | `/api/repos/{owner}/{repo}/runs` | 200 JSON | runs + by_workflow |
| POST | `/webhook/github` | 202 / 401 / 404 | `workflow_run`。secret 必須 |

## Review HTTP（`:8118`）

| メソッド | パス | 成功 | 説明 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | 200 | プローブ |
| GET | `/repos/{owner}/{repo}/pulls` | 200 | PR 一覧 |
| GET | `/repos/{owner}/{repo}/pulls/{n}` | 200 | diff + コメント（HTML エスケープ） |
| GET | `/api/repos/{owner}/{repo}/pulls` | 200 | JSON |
| GET | `/api/repos/{owner}/{repo}/pulls/{n}` | 200 | JSON files/comments |
| POST | `/api/repos/{owner}/{repo}/pulls/{n}/comments` | 201 | GitHub へ転送。トークン無しは 403 |
