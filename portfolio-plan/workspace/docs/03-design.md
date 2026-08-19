# P04 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P04 workspace |
| 対象スライス | 1–7 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

「やりたいこと」は [01-requirements.md](01-requirements.md)。ここでは守り方。

## 1. プロセス構成

現状は 1 リポジトリ `pf-workspace`。

| プロセス | 実装 | 持つ正本 |
| --- | --- | --- |
| `apps/api` | Go, `net/http` + gorilla websocket `/chat/ws` | workspace / member / board / card / page メタ / document メタ / チケット / channel / message / 検索インデックス相当（メモリ） / ローカル添付 / sprint / page_version。本文のスナップショット |
| `apps/collab` | Node, Hocuspocus + Yjs | 接続中の Y.Doc と中継。会員リストは持たない |
| `apps/web` | Next.js 15 App Router | 画面。認可の正ではない。Server Action 経由で API を叩く |

chat WS は API プロセスの `/chat/ws`（JSON）。collab の Yjs とは別ソケット。将来 `pf-workspace-chat` に分ける。空の git は作らない。

## 2. 認証の内部

`internal/auth.Middleware`:

1. `WORKSPACE_DEV_AUTH` かつ `X-Dev-User-Sub` があればその sub
2. なければ `Authorization: Bearer`
3. JWT を JWKS（`{OIDC_INTERNAL_BASE}/.well-known/jwks.json`）で検証。失敗したら userinfo

Web は開発モードなら cookie なしで `X-Dev-User-Sub` を付ける。OIDC 時は `rp_access` cookie を Bearer にする。

## 3. 権限

`service.requireRole(wsID, sub, need)` が唯一の入口。HTTP 層でロールを信じない。

- 読み取り: guest 以上
- ボード作成・カード書き込み: member 以上
- メンバー追加: owner のみ
- ページ書き込み: member 以上。guest の draft GET は `ErrNotFound`（403 にしない）
- 独立ドキュメント作成: member 以上。参照は guest 以上
- collab チケット: 対象の GET と同じ可視性。guest は `readOnly`
- 検索: guest 以上。page は `FilterGuestPages`
- 添付追加: member 以上。参照は親（ページ GET / チャンネル履歴）と同じ
- スプリント書き込み: member 以上。参照とバーンダウンは guest 以上
- Wiki 履歴: GET page と同じ可視性。restore は member 以上

## 4. データ（メモリ）

永続化は `internal/store/memory`。mutex 1 本。再起動で消える。

論理エンティティ:

- Workspace (`id`, `name`, `createdAt`)
- Member (`workspaceId`, `sub`, `role`, `joinedAt`)
- Board / Column / Card
- Page（`parentId`, `body` Markdown スナップショット, `status`, `version`, `collabDocumentId`）
- Document（独立文書。`collabDocumentId`）
- CollabTicket / ChatTicket（sub, 対象, readOnly, expiresAt）
- Channel / ChatMessage（`seq` はチャンネル内 1,2,3…。削除しない。`mentions` は投稿時に解決）
- StoredFile（ローカル一時ファイルまたは P03 fileId。`viewToken` 付き）
- Sprint（`boardId`, `startAt`, `endAt` UTC）
- PageVersion（page ごとの title+body スナップショット。番号は単調増加）

`collabIndex` は `collabDocumentId` → page または document。部屋名の解決に使う。

横断検索は `Search` が pages / documents / cards / messages を走査する。Postgres FTS のふりをしない。本文は API の `body` スナップショット。

添付の実体は Y.Doc に入れない。Wiki は Markdown の画像 URL、チャットは `attachmentFileId`。`MEDIA_API_URL` が空なら `SaveLocalFile`。

ツリーは `domain.BuildPageTree`（隣接リスト → ネスト）。guest 向けは `FilterGuestPages` で draft と draft 祖先付き published を落とす。検索の page ヒットも同じ関数。

本文の正は collab の Y.Doc。API の `body` は起動時シードと debounce スナップショット。タイトル・status・親子は API が正のまま。スナップショットは page の `version` を増やさない（タイトル競合と混ぜない）。

Card の `version` は更新・移動の成功時だけインクリメント。列内 `position` は移動後にその列を 0..n-1 で振り直す。Done 列（名前が `Done`）へ入ると `completedAt` をセットし、外すとクリアする。

バーンダウンは `domain.BurndownFor`。その日終了時点で残っているのは、スプリントに今割り当てられていて、`createdAt` がその日以前、かつ `completedAt` がその日より後または未設定のカード。割り当て履歴の完全ログは持たない。

Wiki 履歴は `AppendPageVersionIfChanged`。title+body が直前と同じなら足さない。collab の debounce スナップショットでも本文が変われば版が増える（page.version は増やさない）。復元は PATCH 相当で lock version を消費し、新しい版を足す。開いている Y.Doc は自動では巻き戻さない。

Postgres に移すときは同じフィールドをテーブルにし、移動はトランザクション + `WHERE version = $expected` にする。今はメモリでその意味をテストする。

## 5. 楽観ロック

CRDT をカンバンに使わない理由: 列と順序は全順序が必要で、Yjs の挿入位置と「Done に移した」が衝突すると面接で説明しにくい。カード本文の同時編集は文書側。

競合時は 409 と最新カードを返す。サーバーがマージしない。

## 6. Web の DnD

`@dnd-kit` は UI の意図だけを作る。確定は `PATCH /v1/cards/:id/move`。失敗したら `router.refresh()`。楽観的に列を入れ替えたまま放置しない（version がずれるため）。

## 7. collab 認可

ブラウザは JWT を WS に直接載せない。API がチケットを出し、collab が `WORKSPACE_INTERNAL_TOKEN` 付きで `POST /internal/v1/collab/authorize` する。

部屋名は `domain.ValidCollabRoom`（ULID）。チケットの `collabDocumentId` と `documentName` が違うと 403。期限切れは 401。

guest のチケット発行は `GetPage` / `GetDocument` と同じ ACL を通す。draft は 404。

Y.Doc は collab プロセスのメモリ。再起動で消え、API スナップショットから再シードする。

IME: `yCollabIME` は `view.composing` 中に CM→Yjs も remote→CM もしない。`compositionend` で prefix/suffix diff を 1 トランザクションにする。y-codemirror.next 標準の ySync は変換中キーを即 Y.Text に書きエコーしてキャレットを飛ばす。

メッセージは `AppendMessage` のあと `Hub.Broadcast`。Hub はメモリ。複数 API レプリカでは届かない（既知）。

## 8. セキュリティ境界

- guest の禁止は API。Web の `readOnly` は補助
- CORS は `WORKSPACE_CORS_ORIGIN`（既定 `http://localhost:3006`）
- 内部 collab 経路は `WORKSPACE_INTERNAL_TOKEN`。空なら内部 API は 401
- 秘密は環境変数。`.env.example` のみコミット

## 9. 既知の制限

- メモリ store。overlay `b-collab` でも同じ。複数 API / collab レプリカではデータが分裂する。sticky は単一 collab 前提。platform Postgres の `workspace` DB は未接続
- カード移動のリアルタイム他ブラウザ同期なし
- 列カスタム・ストーリーポイント未実装
- バーンダウンは現在の割り当てと Done 時刻。過去の割り当て変更は遡及しない
- 日本語 IME は composition 確定まで Yjs に送らない。変換中の同時編集は稀に食い違う
- チケット 15 分。長期編集は再読込が必要
- チャット未読バッジ・既読ウォーターマークは未実装（last_read_seq は後続）
- 検索はメモリ部分一致。プロセス再起動でインデックスも消える
- P03 結合は `MEDIA_API_URL` 任意。単体 Compose はローカル添付
