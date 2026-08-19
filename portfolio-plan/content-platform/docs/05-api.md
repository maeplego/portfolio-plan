# P08 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P08 content-platform |
| 対象スライス | スライス 1 の HTTP。OpenAPI は未作成 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | ブログ `http://localhost:3007`、短縮 `http://localhost:8094` |

エラー本文:

```json
{ "error": { "code": "invalid_url", "message": "only http and https are allowed" } }
```

開発認証: 短縮は `X-Dev-User-Sub`。ブログ管理は同じヘッダまたは cookie `content_dev_sub`。

## 運用（両方）

| メソッド | パス | 認証 | 成功 | 説明 |
| --- | --- | --- | --- | --- |
| GET | `/health` または `/api/health` | なし | 200 `{ "ok": true }` | liveness |
| GET | `/ready` または `/api/ready` | なし | 200 / 503 | store ping |

ブログのヘルスは `/api/health`。短縮は `/health`。

## ブログ公開

### GET `/api/posts`

成功 200 `{ "posts": [ PostSummary ] }`。`bodyMd` なし。公開のみ。

### GET `/api/posts/{id}`

公開済みなら 200 Post。下書きは未認証 404。

Post:

| 欄 | 型 | 意味 |
| --- | --- | --- |
| id | string | ULID |
| slug | string | kebab-case |
| title | string | |
| bodyMd | string | Markdown 原典（詳細時） |
| status | string | `draft` \| `published` |
| tags | string[] | |
| coverUrl | string | `/harbor.svg` または URL |
| author | string | 架空名 |
| publishedAt | string \| null | RFC3339 |

## ブログ管理

### POST `/api/dev-login`

`CONTENT_DEV_AUTH=true` のとき cookie をセット。201 相当ではなく 200 `{ ok, sub:"editor" }`。

### GET `/api/posts?all=1`

編集者。下書き含む。

### POST `/api/posts`

本文 `title, slug, bodyMd, tags, coverUrl, status`。201。

### PATCH `/api/posts/{id}`

部分更新。`status: published` で公開。

### POST `/api/posts/{id}/shorten`

公開記事のみ。短縮 API をサーバから呼ぶ。201 `{ post, link }`。

## 短縮

### POST `/v1/links`

`{ "url", "slug?", "expiresAt?" }` → 201。

```json
{
  "id": "...",
  "code": "Ab3X9kQ",
  "url": "http://localhost:3007/posts/why-redirect-is-not-nextjs",
  "shortUrl": "http://localhost:8094/Ab3X9kQ",
  "active": true,
  "createdBy": "editor",
  "createdAt": "2026-08-19T06:00:00Z",
  "clicks": 0
}
```

### GET `/v1/links` / `/v1/links/{id}` / `/v1/links/{id}/stats`

作成者のみ。stats は `{ link, daily: [{ date, count }] }`。

### GET `/{code}`

302。本文に計測結果を含めない。
