# P04 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P04 workspace |
| 対象スライス | 1–7 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `apps/api` のハンドラとテスト |

OpenAPI ファイルは未作成。本ファイルが HTTP 契約の正本。

## 共通

- Base: `http://localhost:8096`
- Collab WS: `ws://localhost:8097`（HTTP `/health` 同じポート）
- Chat WS: `ws://localhost:8096/chat/ws?ticket=&channelId=`（Yjs ではない）
- 認証: `Authorization: Bearer` または開発時 `X-Dev-User-Sub`
- エラー形は [02-specification.md](02-specification.md) §12

## ヘルス

- `GET /health` → `{ "ok": true }`
- `GET /ready` → `{ "ok": true }`

## ワークスペース

### `POST /v1/workspaces`

入力: `{ "name": "Demo Team" }`  
成功: 201、Workspace（`id`, `name`, `createdAt`）

### `GET /v1/workspaces`

成功: 200 `{ "workspaces": [ ... ] }`

### `GET /v1/workspaces/:id`

成功: 200 Workspace。非所属 403、なし 404。

### `GET /v1/workspaces/:id/members`

成功: 200 `{ "members": [ { "workspaceId", "sub", "role", "joinedAt" } ] }`

### `POST /v1/workspaces/:id/members`

入力: `{ "sub": "guest-1", "role": "guest" }`  
`role` 省略時は `member`。成功 201。owner 指定 403。重複 409。

### `POST /v1/workspaces/:id/boards`

入力: `{ "name": "Sprint 1" }`（空なら `Main board`）  
成功: 201、BoardDetail（board + columns。各 column に `cards: []`）

### `GET /v1/workspaces/:id/boards`

成功: 200 `{ "boards": [ { "id", "workspaceId", "name", "createdAt" } ] }`

### `GET /v1/workspaces/:id/search`

クエリ: `q` 必須。`types` 省略時 `page,document,card,message`。  
成功 200 `{ "hits": [ { "type", "id", "title", "snippet", "hrefHints" } ] }`  
空 q 400。非所属 403。guest の page は FilterGuestPages。

## ボード / カード

### `GET /v1/boards/:boardId`

成功: 200 BoardDetail。

```json
{
  "id": "01...",
  "workspaceId": "01...",
  "name": "Sprint 1",
  "createdAt": "2026-08-18T10:00:00Z",
  "columns": [
    {
      "id": "01...",
      "boardId": "01...",
      "name": "To Do",
      "position": 0,
      "createdAt": "2026-08-18T10:00:00Z",
      "cards": []
    }
  ]
}
```

### `POST /v1/columns/:columnId/cards`

入力: `{ "title": "Task A", "description": "" }`  
成功: 201 Card（`version` は 1）

### `GET /v1/cards/:cardId`

成功: 200 Card。

### `PATCH /v1/cards/:cardId`

入力: `{ "title": "...", "description": "...", "version": 1, "sprintId": "01..." }`  
`sprintId` 省略は変更なし、`""` は解除。成功: 200。不一致 409（`current` を含めてよい）。

### `PATCH /v1/cards/:cardId/move`

入力: `{ "columnId": "01...", "position": 0, "version": 1 }`  
成功: 200。不一致 409。guest 403。

## Wiki

### `POST /v1/workspaces/:id/pages`

入力: `{ "title": "Root", "body": "# Hello", "parentId": "", "status": "published" }`  
`status` 省略時 `draft`。成功 201 Page（`collabDocumentId` 付き）。

### `GET /v1/workspaces/:id/pages/tree`

成功: 200 `{ "tree": [ { "id", "title", "status", "position", "children": [] } ] }`  
本文なし。guest は published のみ。

### `GET /v1/pages/:pageId`

成功: 200 Page（`body` 含む）。guest の draft は 404。

### `PATCH /v1/pages/:pageId`

入力（いずれも任意、`version` 必須）: `{ "title", "body", "status", "parentId", "version": 1 }`  
成功 200。不一致 409。循環 400。guest 403。`body` 省略時はタイトル・状態だけ更新（collab 稼働時）。

## 独立ドキュメント

### `POST /v1/workspaces/:id/documents`

入力: `{ "title": "Notes", "body": "" }`  
成功 201 Document（`collabDocumentId` 付き）。guest 403。

### `GET /v1/workspaces/:id/documents`

成功 200 `{ "documents": [ ... ] }`

### `GET /v1/documents/:id`

成功 200 Document。非所属 403。

### `PATCH /v1/documents/:id`

入力: `{ "title": "..." }`  
成功 200。本文は collab。guest 403。

## collab チケット

### `POST /v1/collab-tickets`

入力: `{ "collabDocumentId": "01..." }`  
成功 201 `{ "ticket", "collabDocumentId", "readOnly", "expiresAt" }`  
部屋名が ULID でない 400。guest の draft ページ 404。

## 内部（collab サーバー専用）

`Authorization: Bearer` に `WORKSPACE_INTERNAL_TOKEN`。ユーザー JWT は使わない。トークン空または不一致は 401。

### `POST /internal/v1/collab/authorize`

入力: `{ "ticket", "documentName" }`  
成功 200 `{ "sub", "collabDocumentId", "readOnly" }`  
チケットと `documentName` 不一致 403。期限切れ 401。

### `POST /internal/v1/collab/plaintext`

入力: `{ "collabDocumentId" }`  
成功 200 `{ "plaintext" }`

### `POST /internal/v1/collab/snapshot`

入力: `{ "collabDocumentId", "plaintext" }`  
成功 200 `{ "ok": true }`。page の `version` は増やさない。100000 文字超は 400。

## チャット

### `GET /v1/workspaces/:id/channels`

成功 200 `{ "channels": [ { "id", "workspaceId", "name", "createdAt" } ] }`  
ワークスペース作成時に `name=general` が 1 件ある。

### `POST /v1/workspaces/:id/channels`

入力: `{ "name": "random" }`  
成功 201。guest 403。

### `POST /v1/channels/:id/messages`

入力: `{ "body": "hello @demo-user-b", "attachmentFileId": "01..." }`  
`attachmentFileId` は任意。成功 201 ChatMessage（`seq`、`mentions`）。guest 403。空かつ添付なし、または 4000 超は 400。

### `GET /v1/channels/:id/messages`

クエリ: `afterSeq`（省略時は全件）  
成功 200 `{ "messages": [ ... ] }`

### `POST /v1/chat-tickets`

入力: `{ "channelId" }`  
成功 201 `{ "ticket", "channelId", "readOnly", "expiresAt" }`

### `GET /chat/ws`

クエリ: `ticket` 必須。`channelId` があればチケットと一致必須。  
アップグレード後、サーバーは `{ "type": "message", "message" }`（`mentions` を含む）と `{ "type": "typing", "sub" }` を送る。クライアントの `{ "type": "typing" }` は永続化しない。メッセージ投稿は REST のみ。

## 添付

### `GET /v1/uploads/config`

成功 200 `{ "provider": "local"|"p03", "maxBytes": 20971520, "mediaApiUrl"? }`

### `POST /v1/uploads`

multipart: `workspaceId`, `purpose`（`wiki`|`chat`）, `file`。成功 201 FileView（`id`, `url`, `name`）。guest 403。20MB 超 413。P03 未設定時のローカル保存。

### `POST /v1/uploads/link`

入力: `{ "workspaceId", "purpose", "fileId", "name", "contentType", "size" }`  
`MEDIA_API_URL` があるときだけ。未設定は 400。成功 201。fileId のみ保存。

### `POST /v1/pages/:id/attachments`

入力: `{ "fileId" }`。purpose=wiki かつ同一ワークスペース。成功 201 FileView。guest 403。guest の draft ページは 404。

### `GET /v1/pages/:id/attachments`

成功 200 `{ "files": [ FileView ] }`。ページ GET と同じ ACL。

### `GET /v1/files/:id`

成功 200 FileView。所属していなければ 403。

### `GET /v1/files/:id/content`

クエリ: `t`（viewToken）。認証ヘッダ不要。成功 200 バイト。トークン不一致 401。ローカル保存のみ。

## スプリント

### `POST /v1/boards/:boardId/sprints`

入力: `{ "name": "Sprint 7", "startAt": "2026-08-01T00:00:00Z", "endAt": "2026-08-14T00:00:00Z" }`  
成功 201 Sprint。guest 403。期間不正・90 日超は 400。

### `GET /v1/boards/:boardId/sprints`

成功 200 `{ "sprints": [ { "id", "boardId", "workspaceId", "name", "startAt", "endAt", "createdAt" } ] }`

### `GET /v1/sprints/:id`

成功 200 Sprint。

### `PATCH /v1/sprints/:id`

入力: `{ "name"?, "startAt"?, "endAt"? }`。成功 200。guest 403。

### `DELETE /v1/sprints/:id`

成功 204。カードの `sprintId` を外す。guest 403。

### `GET /v1/sprints/:id/burndown`

成功 200 `{ "sprintId", "unit": "cards", "points": [ { "date": "2026-08-01", "remaining": 3 } ] }`  
`date` は UTC の暦日。

## Wiki 履歴

### `GET /v1/pages/:id/versions`

成功 200 `{ "versions": [ { "pageId", "number", "title", "sub", "createdAt" } ] }`（body なし）。guest の draft は 404。

### `GET /v1/pages/:id/versions/:n`

成功 200 PageVersion（`body` 含む）。

### `GET /v1/pages/:id/diff?from=&to=`

`from` と `to` 必須で異なる。成功 200 `{ "pageId", "from", "to", "titleChanged", "fromTitle", "toTitle", "lines": [ { "op": "equal"|"delete"|"insert", "text" } ] }`

### `POST /v1/pages/:id/restore`

入力: `{ "number": 1, "version": 3 }`（`version` はページの楽観ロック）。成功 200 Page。guest 403。draft は guest 404。
