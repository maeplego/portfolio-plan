# P04 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P04 workspace |
| 対象スライス | 1–7 の現行 API・Web |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

ユーザーと呼び出し側から見た振る舞い。内部のマップ構造は [03-design.md](03-design.md)。

## 1. 用語

| 用語 | 意味 |
| --- | --- |
| workspace | 権限の境界。ボード・Wiki・（将来）チャットが属する |
| page | Wiki 1 記事。`parentId` 空はルート。本文は Markdown。同時編集時の正は CRDT |
| document | Wiki ツリーに載らない独立文書。本文の正は CRDT |
| collab ticket | WS 接続用の短命トークン。部屋名（`collabDocumentId`）とセット |
| status | `draft` または `published` |
| role | `owner` / `member` / `guest` |
| board | カンバン 1 枚。作成時に 3 列が付く |
| card.version | 楽観ロック用整数。更新・移動のたびに +1 |
| 開発モード | `WORKSPACE_DEV_AUTH=true` かつ OIDC 未設定。Web は `?user=` で sub を切替 |

## 2. 認証の外部契約

1. **API の `/v1/*` は認証必須。** ヘッダなしは 401。
2. **開発:** `X-Dev-User-Sub: <sub>` を API が信じるのは `WORKSPACE_DEV_AUTH=true` のときだけ。
3. **OIDC:** `Authorization: Bearer`。JWT（issuer / 任意 audience）または opaque + userinfo。Web は `/login` → `/callback` で cookie に access token を置く。
4. **単体デモ既定は開発モード。** OIDC を「必須で動く」とは書かない。

## 3. ロール

| 操作 | owner | member | guest | 非所属 |
| --- | --- | --- | --- | --- |
| ワークスペース一覧に出る | 可 | 可 | 可 | 否 |
| メンバー追加 | 可 | 否 | 否 | 否 |
| ボード作成 | 可 | 可 | 否 | 否 |
| ボード参照 | 可 | 可 | 可 | 否 |
| カード作成・更新・移動 | 可 | 可 | 否 | 否 |
| Wiki ツリー参照 | 可（全） | 可（全） | 可（published のみ） | 否 |
| ページ GET | 可 | 可 | published のみ。draft は 404 | 否 |
| ページ作成・更新 | 可 | 可 | 否 | 否 |
| 独立ドキュメント作成 | 可 | 可 | 否 | 否 |
| 独立ドキュメント参照 | 可 | 可 | 可 | 否 |
| collab 編集 | 可 | 可 | 閲覧のみ（read-only WS） | 否 |
| チャンネル参照 | 可 | 可 | 可 | 否 |
| メッセージ投稿 | 可 | 可 | 否 | 否 |
| 横断検索 | 可 | 可 | 可（draft 除外） | 否 |
| 添付追加 | 可 | 可 | 否 | 否 |
| 添付参照 | 可（親と同じ） | 可 | 可（親と同じ） | 否 |
| スプリント参照 / バーンダウン | 可 | 可 | 可 | 否 |
| スプリント作成・カード割り当て | 可 | 可 | 否 | 否 |
| Wiki 履歴 / diff | 可 | 可 | 可（published のみ） | 否 |
| Wiki 復元 | 可 | 可 | 否 | 否 |

guest のボード画面は「閲覧のみ」と表示する。UI を隠しても API は 403 を返す。

## 4. ワークスペース

- 作成: `name` 必須。空なら 403（不正入力の簡易扱い）。作成者は自動で owner。
- 一覧: 自分が所属するものだけ。作成日時昇順。
- 詳細: 所属していなければ 403。存在しなければ 404。
- メンバー追加: `sub` と `role`（`member` または `guest`）。既存メンバーは 409。`owner` 指定は 403。

## 5. カンバン

### 5.1 ボード

- 作成時の既定列名は `To Do`、`In Progress`、`Done`（この順、`position` 0..2）。
- 列の追加・削除・改名は未実装。

### 5.2 カード

- 作成: 列に末尾追加。`version` は 1。空タイトルは 403。
- 更新: `title` / `description` / 任意の `sprintId` と **現在の** `version` を送る。不一致は 409。成功すると `version` が 1 増える。`sprintId` 省略は変更なし、空文字は解除。他ボードのスプリントは 400。
- 移動: `columnId`（同一ボード内）、`position`（0 始まり）、`version`。列をまたいでも同一ボードでなければ 403。Done 列に入ると `completedAt` を付ける。
- 他ボードの列へ移すことはできない。

### 5.3 競合（外部から見える結果）

2 クライアントが同じカードを、同じ `version` でほぼ同時に PATCH した場合、**200 が 1 件と 409 が 1 件**。どちらが 200 かは規定しない。409 の本文に `current` カードを含めてよい。クライアントは再取得してからやり直す。

### 5.4 スプリント

- 作成: `POST /v1/boards/:boardId/sprints` `{ name, startAt, endAt }`（RFC3339 UTC）。終了は開始より後。カレンダー日数は 90 日まで。guest 403。
- 一覧・詳細・バーンダウンは guest 以上。
- バーンダウン: `GET /v1/sprints/:id/burndown`。単位は `cards`。Done 列（名前 `Done`）へ入った時刻を完了とみなす。現在の割り当てと `createdAt` / `completedAt` から日次 remaining を出す（移動イベントの完全ログではない）。
- 削除するとカードの `sprintId` を外す（カード version は増やさない）。

## 6. Web（スライス 2）

| 画面 | 仕様 |
| --- | --- |
| `/` | ワークスペース一覧。作成フォーム。ボード追加。メンバー追加（owner）。Wiki / Docs / Chat / 検索へのリンク。OIDC 有効かつ未ログインなら `/login` |
| `/boards/:boardId` | 3 列カンバン。カード追加、DnD 移動、カード詳細モーダル（スプリント割り当て）。guest は DnD 無効 |
| `/boards/:boardId/sprints` | スプリント作成とバーンダウン（未完了カード数） |
| `/wiki/:workspaceId` | Wiki ツリー |
| `/wiki/:workspaceId/pages/:pageId` | Wiki エディタ（collab または textarea）と履歴 diff |
| `/docs/:workspaceId` | 独立ドキュメント一覧 |
| `/docs/:workspaceId/:documentId` | 共同編集エディタ |
| `/chat/:workspaceId` | チャンネル一覧 |
| `/chat/:workspaceId/:channelId` | タイムライン。guest は投稿フォームなし。自分宛メンションは強調 |
| `/search/:workspaceId` | 横断検索結果。種別バッジ。`?user=` を維持 |
| `/login` `/callback` `/logout` | OIDC。開発モードでは使わない |

開発モードのユーザー切替は `/?user=demo-user-a` と `demo-user-b`。A のワークスペースは B の一覧に出ない。

## 7. Wiki

- 作成: `title` 必須。`parentId` 省略でルート。既定 `status=draft`。`collabDocumentId` は作成時に発行し、スライス 4 で collab 部屋名になる。
- ツリー: `GET .../pages/tree`。本文は含めない。guest には published だけ。親が draft の published 子も出さない。
- 取得: 本文込み（API 上のスナップショット。編集中は CRDT が先）。guest が draft を叩くと 404（存在を漏らさない）。
- 更新: `version` 必須。不一致 409。`parentId` を自分または子孫にすると 400。collab 稼働時のタイトル・状態保存は `body` を省略してよい。
- 表示: collab 接続時は CodeMirror + Yjs。未接続は textarea + プレビュー。`react-markdown` は raw HTML を出さず、`javascript:` はリンクにしない。
- 画面: `/wiki/:workspaceId` と `/wiki/:workspaceId/pages/:pageId`
- 履歴: 作成時と title/body 変更時（collab スナップショットで本文が変わったときも含む）に API スナップショットを足す。Y.Doc バイトは保存しない。`GET .../versions` は本文なし。`GET .../versions/:n` は本文あり。`GET .../diff?from=&to=` は行単位 LCS。`POST .../restore` `{ number, version }` でその版の title+body を戻し、新しい版を足す。guest は GET page と同じ可視性（draft は 404）。restore は member 以上。

## 8. 共同編集（collab）

- チケット: `POST /v1/collab-tickets` `{ "collabDocumentId" }`。有効 15 分。guest の draft ページは 404。guest の published / ドキュメントは `readOnly: true`。
- 部屋名は ULID のみ。`../` のような名前は 400。
- ブラウザはチケットを Hocuspocus の token として `ws://localhost:8097` に渡す。サーバーは API の内部認可でチケットと部屋の一致を確認する。
- 空の Y.Doc は API のプレーンテキストで初期化する。debounce 後にスナップショットを API へ戻す（検索用。スライス 6 で使う）。
- 独立ドキュメント: `POST/GET /v1/workspaces/:id/documents`、`GET/PATCH /v1/documents/:id`（PATCH は title）。画面 `/docs/:workspaceId`。
- 2 ウィンドウ手順と IME 制限は製品 README。IME は composition 中に Yjs へ送らない。

## 9. チャット

- ワークスペース作成時に `general` チャンネルが 1 つ付く。追加は member 以上。
- 投稿: `POST /v1/channels/:id/messages` `{ "body", "attachmentFileId"? }`。成功すると `seq` が +1。空かつ添付なし、または 4000 超は 400。guest 403。`mentions` は本文の `@sub` をメンバーに解決した配列。
- 履歴: `GET /v1/channels/:id/messages?afterSeq=N`。`afterSeq` 省略で全件。本文はプレーンテキスト（HTML にしない）。
- 配信: 永続化したあと `/chat/ws?ticket=&channelId=` で `{ type: "message", message }`（`mentions` を含む）。Yjs ソケットとは別。
- typing: WS で `{ type: "typing" }`。サーバーは永続化せず `{ type: "typing", sub }` を配る。クライアントは 400ms debounce。
- 再接続: WS open 時に `afterSeq` で差分 GET。
- 画面: `/chat/:workspaceId` と `/chat/:workspaceId/:channelId`。既知メンバーの `@` 補完。メール / Push / 未読は出さない。

## 10. 横断検索

- `GET /v1/workspaces/:id/search?q=&types=`
- `q` 空（空白のみ含む）は 400。非所属 403。
- `types` 省略時は `page,document,card,message`。未知の種別は 400。
- 照合はメモリの大小無視部分一致。Wiki 本文は API スナップショット（その場の Y.Doc ではない）。
- guest の page ヒットは `FilterGuestPages` と同じ（draft と draft 配下の published は出ない）。カードとメッセージは閲覧できる範囲どおりヒットする。
- ヒット: `{ type, id, title, snippet, hrefHints }`。Wiki は pageId、カードは boardId+cardId、チャットは channelId+seq。
- 画面: ホームの各ワークスペースに検索欄 → `/search/:workspaceId?q=`。権限外を UI で隠すことは認可ではない。

## 11. 添付

- チャット: 投稿の任意 `attachmentFileId`。purpose=chat のファイルだけ。
- Wiki: `POST /v1/pages/:id/attachments` `{ "fileId" }`。Markdown に画像 URL を貼る。プレビューは既存どおり raw HTML / `javascript:` 禁止。
- `MEDIA_API_URL` があるとき: P03 `presign`（`purpose=wiki|chat`）→ `complete` → workspace に fileId だけ保存。
- 未設定時: `POST /v1/uploads` でメモリ + 一時ファイル。`GET /v1/files/:id/content?t=` が署名 URL 相当（20MB を超えない）。
- ファイルバイトを Yjs に載せない。guest は追加 403。参照は親リソースと同じ ACL（トークン付き GET は親に貼られた URL を開く）。
- 単体 Compose に media は含めない。

## 12. エラー形

```json
{ "error": { "code": "not_found" | "forbidden" | "conflict" | "invalid_request", "message": "..." } }
```

| HTTP | code | とき |
| --- | --- | --- |
| 400 | invalid_request | JSON 不正、ページの循環親、本文超過、部屋名が ULID でない、空の検索 q、スプリント期間不正、同一版 diff |
| 401 | unauthorized / プレーン | 未認証、期限切れチケット、内部トークン欠如、添付トークン不一致 |
| 403 | forbidden | ロール不足・空タイトル・チケットと部屋の不一致 |
| 404 | not_found | 対象なし。guest の draft チケットも含む |
| 409 | conflict | version 不一致、メンバー重複 |
| 413 | too_large | 添付が 20MB 超 |
