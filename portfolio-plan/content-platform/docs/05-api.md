# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | コンテンツ基盤（GitHub: `pf-content-blog`、`pf-content-shortener`） |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

基準 URL はブログ `http://localhost:3007`、短縮 `http://localhost:8094`。OpenAPI ファイルは未作成。

エラー本文:

```json
{ "error": { "code": "invalid_url", "message": "only http and https are allowed" } }
```

### 開発認証（DEV_AUTH）

| 面 | 環境変数 | ヘッダ / cookie |
| --- | --- | --- |
| ブログ管理 | `CONTENT_DEV_AUTH=true` | cookie `content_dev_sub`、または `X-Dev-User-Sub` |
| 短縮 API | `SHORTENER_DEV_AUTH=true`（必須） | `X-Dev-User-Sub` |

ブログ OIDC（任意）: `OIDC_ISSUER`、`OIDC_CLIENT_ID`、`OIDC_REDIRECT_URI`、任意 `OIDC_INTERNAL_BASE` / `OIDC_POST_LOGOUT_REDIRECT_URI`。Compose 例は `pf-content-infra/deploy/.env.example` のコメント。**短縮の P01 OIDC は staging 向け設計のみ（未実装）。**

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

### GET `/posts/{slug}/opengraph-image`

公開記事の題名画像。下書きの題は出さない。

## ブログ管理

### POST `/api/dev-login`

`CONTENT_DEV_AUTH=true` のとき cookie をセット。200 `{ ok, sub:"editor" }`。OIDC 有効時は使わない。

### GET `/api/posts?all=1`

編集者。下書き含む。

### POST `/api/posts`

本文 `title, slug, bodyMd, tags, coverUrl, status`。201。

### PATCH `/api/posts/{id}`

部分更新。`status: published` で公開。

### POST `/api/posts/{id}/shorten`

公開記事のみ。短縮 API をサーバから呼ぶ。201 `{ post, link }`。

### POST `/api/draft` / DELETE `/api/draft`

編集者のみ Draft Mode を切替。GET は `{ draft, editor }`。

### GET `/api/short-links` / `?id=`

編集者。短縮一覧、または 1 件の日次 stats。

## 短縮

### POST `/v1/links`

`{ "url", "slug?", "expiresAt?" }` → 201。`SHORTENER_DEV_AUTH` + `X-Dev-User-Sub`。

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

302。本文に計測結果を含めない。クライアント単位のレート制限超過は 429。
