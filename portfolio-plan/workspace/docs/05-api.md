# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | チーム作業場所 [pf-workspace](https://github.com/maeplego/pf-workspace) |
| 最終更新 | 2026-08-20 |
| 実装との関係 | `apps/api` のハンドラとテストを優先する |

OpenAPI ファイルは未作成。本ファイルが HTTP 契約の要約。

## 共通

- Base: `http://localhost:8096`
- Collab WS: `ws://localhost:8097`（HTTP `/health` 同じポート）
- Chat WS: `ws://localhost:8096/chat/ws?ticket=&channelId=`（Yjs ではない）
- 認証: `Authorization: Bearer` または開発時 `X-Dev-User-Sub`（任意 `X-Dev-User-Email`, `X-Dev-User-Org`）
- エラー形は [02-specification.md](02-specification.md) §12

## ヘルス

- `GET /health` → `{ "ok": true }`
- `GET /ready` → `{ "ok": true }`

## ワークスペース

### `POST /v1/workspaces`

入力: `{ "name": "Demo Team" }`  
成功: 201、Workspace（`id`, `name`, `orgId`, `createdAt`）。`orgId` は IdP の `org_id` claim（`org` scope）から自動設定。未所属時は空文字。

### `GET /v1/workspaces`

成功: 200 `{ "workspaces": [ ... ] }`

### `GET /v1/org-members?q=`

アクティブ org（JWT `org_id`）のメンバー候補を返す。owner の招待補助用。  
成功: 200 `{ "members": [ { "sub", "role", "email?", "displayName?" } ] }`。  
`q` 指定時は `sub` / `email` / `displayName` の部分一致。Bearer 時は IdP org members を proxy。

### `GET /v1/workspaces/:id`

成功: 200 Workspace。非所属 403、なし 404。

### `GET /v1/workspaces/:id/members`

成功: 200 `{ "members": [ { "workspaceId", "sub", "displayName", "role", "joinedAt" } ] }`

### `GET /v1/workspaces/:id/members/:sub`

所属 member 以上。成功 200 Member。非所属 403、なし 404。

### `PUT /v1/workspaces/:id/members/me`

入力: `{ "displayName": "表示名" }`。ログイン中ユーザーの当 WS メンバー行を更新。成功 200 Member。

### `PATCH /v1/workspaces/:id/members/:sub`

owner のみ。入力: `{ "role": "member" | "guest" }`（`owner` への昇格は不可 → 400）。  
対象が唯一の owner のとき demote は 403。成功 200 Member。監査 `workspace.member.role_updated`。

### `DELETE /v1/workspaces/:id/members/:sub`

owner のみ。他メンバーを除名。自分自身は不可（400）。唯一の owner の除名は 403。成功 204。監査 `workspace.member.removed`。

### `POST /v1/workspaces/:id/leave`

所属メンバーが自分で退出。唯一の owner は 403。成功 204。監査 `workspace.member.left`。

### `POST /v1/workspaces/:id/members`（レガシー / 開発用）

入力: `{ "sub": "guest-1", "role": "guest" }`  
UI からは非推奨。**通常は招待リンクで参加**。owner のみ。成功 201。owner 指定 403。重複 409。

### `POST /v1/workspaces/:id/invitations`

owner のみ。入力: `{ "role": "member", "maxUses": 1, "ttlHours": 72, "invitedEmail": "guest@example.com" }`  
`invitedEmail` は任意。指定時は accept 側の検証済み email claim と一致必須（不一致 403）。
成功 201 `{ "invitation": { ... }, "token": "<一度だけ返る平文トークン>" }`。DB には `sha256(token)` のみ保存。

### `POST /v1/workspaces/:id/invitations/:inviteId/revoke`

owner のみ。有効な招待を無効化（`revoked_at` 設定）。成功 200 Invitation。既に revoke 済みは冪等 200。存在しない 404。

### `POST /v1/workspaces/:id/invitations/:inviteId/resend`

owner のみ。既存招待の `role` / `invitedEmail` / `maxUses` を引き継いだ新しい招待を再発行。
成功 200 `{ "invitation": { ... }, "token": "<新しい平文トークン>" }`。元招待は自動 revoke しない（必要なら別途 revoke）。

### `PATCH /v1/workspaces/:id/invitations/:inviteId`

owner のみ。既存招待の policy を更新（トークンは維持）。入力（いずれも任意、最低 1 つ）:
`{ "role", "maxUses", "ttlHours", "invitedEmail" }`。
`ttlHours` 指定時は `expiresAt = now + ttlHours`。`maxUses` は現在の `useCount` 未満にできない。revoked 招待は 403。
成功 200 Invitation。監査 `workspace.invitation.policy_updated`。

### `GET /v1/workspaces/:id/invitations`

owner のみ。成功 200 `{ "invitations": [ ... ] }`（トークン平文は含まない）。

### `GET /v1/invitations/:token`

認証必須。副作用なし preview。成功 200 `{ "workspace", "invitation" }`。無効・期限切れ 404。

### `POST /v1/invitations/:token/accept`

認証必須。成功 200 `{ "member", "workspace" }`。既参加 409。上限・期限 404。email 不一致 403。

Web 参加 URL: `/join/{token}`

### `GET /v1/workspaces/:id/audit-events`

owner のみ。成功 200 `{ "events": [ { "type", "actorSub", "targetSub", "inviteId", "createdAt" } ] }`  
種別例: `workspace.invitation.created`, `workspace.invitation.accepted`, `workspace.invitation.revoked`, `workspace.invitation.resent`, `workspace.invitation.policy_updated`, `workspace.member.role_updated`, `workspace.member.removed`, `workspace.member.left`

### `POST /v1/workspaces/:id/boards`

入力: `{ "name": "Sprint 1" }`（空は 400）  
成功: 201、BoardDetail（board + columns。各 column に `cards: []`）

### `GET /v1/workspaces/:id/boards`

成功: 200 `{ "boards": [ ... ], "archivedBoards": [ ... ] }`

### `POST /v1/boards/:id/archive` / `unarchive`

member 以上。204。カードは消さない。

### `POST /v1/pages/:id/archive` / `unarchive`

子孫も含めて `archivedAt` を付ける／外す。Wiki 版の復元は従来どおり `POST /v1/pages/:id/restore`。

### `POST /v1/documents/:id/trash` / `untrash`

ゴミ箱。本文は残る。ゲストの一覧には出さない。

チャンネル・チャットメッセージ・添付の DELETE は提供しない（やりとりの監査用）。

### `GET /v1/workspaces/:id/search`

クエリ: `q` 必須。`types` 省略時 `page,document,card,message`。  
成功 200 `{ "hits": [ { "type", "id", "title", "context", "snippet", "hrefHints" } ] }`  
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

成功 200 `{ "channels": [ { "id", "workspaceId", "name", "createdAt", "lastReadSeq", "unreadCount" } ] }`  
ワークスペース作成時に `name=general` が 1 件ある。`lastReadSeq` / `unreadCount` は呼び出しユーザー基準。

### `POST /v1/workspaces/:id/channels`

入力: `{ "name": "random" }`  
成功 201。guest 403。

### `POST /v1/channels/:id/read`

入力: `{ "lastSeq": N }`。所属者が既読カーソルを単調更新。成功 200 ChannelView。

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

multipart: `workspaceId`, `purpose`（`wiki`|`chat`）, `file`。成功 201 FileView（`id`, `url`, `name`）。guest 403。20MB 超 413。メディア未設定時のローカル保存。

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
