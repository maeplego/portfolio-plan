# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | チーム作業場所 [pf-workspace](https://github.com/maeplego/pf-workspace) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | コードと [05-api.md](05-api.md) を優先する |
| 記法 | Mermaid |

## ユースケース（現行）

```mermaid
flowchart LR
  owner[owner]
  member[member]
  guest[guest]

  owner --> createWs[ワークスペース作成]
  owner --> addMember[メンバー追加]
  owner --> editBoard[カード作成・移動]
  member --> editBoard
  guest --> readBoard[ボード閲覧]
  owner --> readBoard
  member --> readBoard
  owner --> editWiki[Wiki 編集]
  member --> editWiki
  guest --> readWiki[Wiki 閲覧 published]
  owner --> readWiki
  member --> readWiki
  owner --> editDoc[Docs 同時編集]
  member --> editDoc
  guest --> readDoc[Docs 閲覧]
  owner --> chat[チャット投稿]
  member --> chat
  guest --> readChat[チャット閲覧]
  owner --> search[横断検索]
  member --> search
  guest --> searchGuest[検索 published のみ]
  owner --> attach[添付追加]
  member --> attach
  owner --> sprint[スプリント作成]
  member --> sprint
  guest --> readSprint[バーンダウン閲覧]
  owner --> wikiHist[Wiki 履歴 / 復元]
  member --> wikiHist
  guest --> wikiDiff[Wiki diff published]
```

未読バッジは未実装。

## 画面遷移（実装済み）

```mermaid
flowchart TD
  home["/ ワークスペース一覧"]
  board["/boards/:id カンバン"]
  login["/login OIDC"]
  cb["/callback"]

  home -->|ボード| board
  board -->|スプリント| sprints["/boards/:id/sprints"]
  sprints --> board
  board -->|パンくず| home
  home -->|Wiki| wiki["/wiki/:wsId"]
  wiki --> page["/wiki/:wsId/pages/:id"]
  page --> wiki
  home -->|Docs| docs["/docs/:wsId"]
  docs --> doc["/docs/:wsId/:id"]
  doc --> docs
  home -->|Chat| chat["/chat/:wsId"]
  chat --> room["/chat/:wsId/:channelId"]
  room --> chat
  home -->|検索| search["/search/:wsId"]
  home -->|OIDC 有効かつ未ログイン| login
  login --> cb
  cb --> home
```

開発モードでは login を経由しない。

## シーケンス: カード移動成功

```mermaid
sequenceDiagram
  actor U as ブラウザ
  participant W as Next.js
  participant A as workspace-api
  U->>W: DnD drop
  W->>A: PATCH /v1/cards/:id/move version=n
  A->>A: member 以上か
  A->>A: version == n なら移動して n+1
  A-->>W: 200 card
  W->>W: router.refresh GET board
```

## シーケンス: version 競合

```mermaid
sequenceDiagram
  actor A1 as クライアントA
  actor A2 as クライアントB
  participant API as workspace-api
  A1->>API: move version=1
  A2->>API: move version=1
  API-->>A1: 200 version=2
  API-->>A2: 409 current.version=2
```

どちらが 200 かは規定しない。

## シーケンス: collab 接続

```mermaid
sequenceDiagram
  actor U as ブラウザ
  participant W as Next.js
  participant A as workspace-api
  participant C as collab
  U->>W: ページ / Docs を開く
  W->>A: POST /v1/collab-tickets
  A-->>W: ticket, readOnly
  U->>C: WS 部屋=collabDocumentId token=ticket
  C->>A: POST /internal/v1/collab/authorize
  A-->>C: sub, readOnly
  C-->>U: Yjs sync
  C->>A: POST /internal/v1/collab/snapshot（debounce）
```

チケットと部屋が違うと authorize は 403。guest の draft はチケット自体が 404。

## シーケンス: チャット投稿

```mermaid
sequenceDiagram
  actor U as ブラウザ
  participant W as Next.js
  participant A as workspace-api
  participant H as chat hub
  U->>W: 送信
  W->>A: POST /v1/channels/:id/messages
  A->>A: member 以上なら seq+1 で保存
  A->>H: Broadcast message
  H-->>U: WS type=message
  A-->>W: 201 ChatMessage
```

再接続は WS open のあと `GET .../messages?afterSeq=`。

## シーケンス: 横断検索（guest）

```mermaid
sequenceDiagram
  actor G as guest
  participant A as workspace-api
  G->>A: GET /v1/workspaces/:id/search?q=pineapple
  A->>A: requireRole guest+
  A->>A: FilterGuestPages のあと部分一致
  A-->>G: hits（draft なし）
```

空 q は 400。非所属は 403。

## シーケンス: ローカル添付

```mermaid
sequenceDiagram
  actor U as member
  participant W as Next.js
  participant A as workspace-api
  U->>W: 画像選択
  W->>A: POST /v1/uploads multipart
  A-->>W: fileId, url
  alt Wiki
    W->>A: POST /v1/pages/:id/attachments
    Note over W: Markdown に url を貼る。Yjs にはバイトを入れない
  else Chat
    W->>A: POST /v1/channels/:id/messages attachmentFileId
  end
```

guest の upload は 403。

## シーケンス: バーンダウン

```mermaid
sequenceDiagram
  actor U as member
  participant A as workspace-api
  U->>A: POST /v1/boards/:id/sprints
  A-->>U: 201 Sprint
  U->>A: PATCH /v1/cards/:id sprintId
  U->>A: PATCH /v1/cards/:id/move Done
  Note over A: completedAt をセット
  U->>A: GET /v1/sprints/:id/burndown
  A-->>U: points[] remaining cards
```

guest の作成は 403。GET は 200。

## シーケンス: Wiki 履歴 diff

```mermaid
sequenceDiagram
  actor U as member
  participant A as workspace-api
  U->>A: PATCH /v1/pages/:id body
  Note over A: AppendPageVersionIfChanged
  U->>A: GET /v1/pages/:id/diff?from=1&to=2
  A-->>U: lines op equal/delete/insert
  U->>A: POST /v1/pages/:id/restore number=1 version
  A-->>U: 200 Page（新しい版）
```

guest の draft 履歴は 404。restore は 403。

## 論理 ER

DDL は `pf-workspace/apps/api/internal/store/postgres/schema.sql`。id は ULID（TEXT）、時刻は timestamptz。

```mermaid
erDiagram
  WORKSPACE ||--o{ MEMBER : has
  WORKSPACE ||--o{ BOARD : has
  BOARD ||--|{ COLUMN : has
  COLUMN ||--o{ CARD : has
  WORKSPACE {
    string id
    string name
  }
  MEMBER {
    string sub
    string role
  }
  WORKSPACE ||--o{ PAGE : has
  PAGE ||--o{ PAGE : parent
  WORKSPACE ||--o{ DOCUMENT : has
  WORKSPACE ||--o{ CHANNEL : has
  CHANNEL ||--o{ CHAT_MESSAGE : has
  WORKSPACE ||--o{ STORED_FILE : has
  PAGE ||--o{ STORED_FILE : wiki_attach
  BOARD ||--o{ SPRINT : has
  SPRINT ||--o{ CARD : assigned
  PAGE ||--o{ PAGE_VERSION : history
  PAGE {
    string parentId
    string status
    int version
    string collabDocumentId
  }
  DOCUMENT {
    string collabDocumentId
  }
  CHANNEL {
    string name
  }
  CHAT_MESSAGE {
    int seq
    string body
    string mentions
    string attachmentFileId
  }
  STORED_FILE {
    string purpose
    string provider
  }
  SPRINT {
    string name
    datetime startAt
    datetime endAt
  }
  PAGE_VERSION {
    int number
    string title
  }
```
