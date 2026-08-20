# P04 workspace — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/01-sprint-kanban-task-manager.md`
- `portfolio-idea/02-team-knowledge-wiki.md`
- `portfolio-idea/12-realtime-chat-notifications.md`
- `portfolio-idea/26-collaborative-markdown-editor.md`

メディア結合時は `media-platform/DESIGN.md`。認証は `identity-platform/DESIGN.md`。

## 対応アイデア

- 01 スプリント対応カンバン
- 02 チーム向け Wiki
- 12 リアルタイムチャット
- 26 共同編集ドキュメント

## 目的

小さな開発チームの **作業場所** を 1 製品にする。Linear + Notion + Slack の極小版。共通のワークスペース・メンバー・権限の上に、ボード / ページ / チャンネル / 共同編集文書を載せる。

4 つを別製品にすると招待・権限・検索が 4 回生まれ、就職活動の物語も「同じ CRUD を 4 回」に見える。逆に 1 プロセスに全部詰めると、共同編集とチャットの接続特性が壊れる。

## リポジトリ構成（ポリレポ）

スケールと障害影響でプロセスを分ける。ドメインモデル（ワークスペース、メンバー）は 1 つの API が正。

開始は **1 製品リポジトリ** `../pf-workspace`（`apps/api` + `apps/collab` + `apps/web` + `deploy`）。連携デモは `deploy/k8s/`（api / collab / web を別 Service。Yjs とチャット WS を混ぜない）。collab / chat を独立デプロイしたくなったら下表どおり分割する。空の collab リポジトリを先に作らない（P10 の search と同じ段階化）。

| 将来の分割先 | 役割 | 元アイデア |
| --- | --- | --- |
| `apps/web`（のち `pf-workspace-web`） | シェル（左ナビ）、ボード、Wiki ツリー、チャット UI、エディタ | すべて |
| `apps/api`（のち `pf-workspace-api`） | ワークスペース、権限、カンバン、Wiki メタデータ、検索インデックス更新、通知設定 | 01, 02 |
| `pf-workspace-collab` | Yjs / Hocuspocus。文書と Wiki 本文の CRDT 同期 | 26, 02 の本文 |
| `pf-workspace-chat` | WebSocket、メッセージ永続化、presence、未読 | 12 |

collab と chat を後から分ける理由: sticky 接続でスケール単位が違う。api をデプロイしても編集中セッションを落としたくない。共有 TypeScript 型は OpenAPI 生成で補う。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| Web | Next.js, TypeScript, dnd-kit, TipTap または CodeMirror + Yjs, TanStack Query |
| API | Go または NestJS。チームが TypeScript に寄るなら NestJS で web と型を近づけてよい。分散の説明を厚くするなら Go |
| Collab | Hocuspocus または y-websocket、Node.js |
| Chat | Go または Node + Socket.IO。Redis Pub/Sub で複数インスタンスに備える |
| DB | PostgreSQL（api と chat でスキーマ分割。物理 DB は開発時 1 つでも可） |
| 検索 | Postgres FTS。Wiki とカード |
| 添付 | P03。未完成時は API のローカル保存 |

推奨の割り切り: **api = Go, collab = Node, chat = Go, web = Next.js**。言語が 2 つに収まる。

## 設計思想

- **1 ワークスペース、1 権限モデル。** ボードも Wiki もチャットも `workspace_id` + ロール（owner/member/guest）
- **本文の正は CRDT、ツリーと ACL の正は API。** Wiki の親子関係を Yjs だけで持たない
- **メッセージは DB に書いてから配る。** WS だけの記憶にしない
- **カンバンの競合は version / 楽観ロック。** 共同編集の CRDT をカード移動に使わない
- **モジュールは独立デモ可能。** チャットを落としてもボードは動く

## モジュール境界

| モジュール | 持つもの | 持たないもの |
| --- | --- | --- |
| カンバン | カード、列、スプリント、コメント | ファイル実体、Wiki 本文 |
| Wiki | ツリー、権限、検索用プレーンテキスト、履歴メタ | 同時編集のバイト同期 |
| Collab | Y.Doc 永続化、カーソル | 会員リストの正（API を信じる） |
| Chat | メッセージ、seq、既読 | カンバン通知の永続（イベントを受けるだけ） |

Wiki ページ作成: API が `page` 行と collab document id を作る。編集は collab。検索は collab の定期スナップショットまたは debounce したプレーンテキストを API が受ける。

## 実装順序（重要）

一気に 4 機能を始めない。

1. ✅ ワークスペース CRUD、メンバー、OIDC ログイン準備（web + api）。単体デモは `WORKSPACE_DEV_AUTH`
2. ✅ カンバン MVP（DnD、カード詳細、楽観ロック）。Compose / overlay は Postgres。単体テストはメモリ
3. ✅ Wiki ツリー + 単一ユーザー Markdown（まだ CRDT なし）。本文は API が正。guest は published のみ
4. ✅ collab を Wiki 本文と独立ドキュメントに接続。2 ブラウザデモ
5. ✅ チャット（履歴 REST + WS + seq）
6. ✅ 横断検索、メンション、添付（P03 任意 + ローカルフォールバック）
7. ✅ スプリントバーンダウン、Wiki 履歴 diff

## 実装上の注意点

- guest は公開リンク相当。ボードのカード移動を禁止するなど、ロールをサーバーで強制
- チャットの `seq` はチャンネル内単調増加。再接続は `afterSeq`
- typing イベントは永続化しない。debounce する
- 巨大 diff や巨大 Y.Doc のサイズ上限
- Markdown プレビューの XSS。共同編集でもサニタイズは表示側
- 日本語 IME は composition 中に Y.Text へ送らない（確定時に一括）。README に残る制限は変換中の同時編集
- 検索から権限外ページを出さない（アイデア 02 の核心）
- リアルタイムを 3 種類（カード移動、CRDT、チャット）混ぜた単一ソケットにしない。プロトコルが腐る

## 他プロジェクトとの契約

- P01: OIDC。`sub` を workspace member に紐づける。Compose は `WORKSPACE_DEV_AUTH`。overlay `b-collab` の web は `pf-workspace-web` 必須
- P03: 添付 `purpose=wiki|chat`。overlay では `MEDIA_API_URL` を cluster 内 media-api に向ける
- P11: overlay B に portal MVP（`portal.localhost`）。scanner / CI dash は非搭載。CLI テンプレは別リポジトリ
- P05: 将来ワークスペースから面談枠を取るが、P04 MVP の範囲外

## デモ

- 2 ブラウザでカード移動と同時編集とチャットが同時に見える（落ちても他が生きることも見せる）
- guest リンクで Wiki は読めてボードは触れない
- overlay B: `http://workspace.localhost` で IdP ログイン。永続化は platform Postgres の `workspace` DB（`WORKSPACE_DATABASE_URL`）

## 非目標

- 音声・ビデオ
- E2EE チャット
- GitHub 双方向同期（カンバンの発展。P11 の code-review と混ぜない）

## マルチテナント基盤の段階化（2026-08）

### Phase 1（今回実装）

- メンバー追加の `sub` 手入力フローを廃止し、**招待リンク経由の参加**に統一
- owner が招待を発行（`role`, `expires_at`, `max_uses`）
- 参加は「認証済みユーザー」が `accept` して membership を作成
- 招待作成/受諾を監査イベントとして保存（アプリケーション層）
- 招待トークンは平文保存せず、`sha256(token)` のみ DB に保存

### Phase 2（実装済み: IdP 連携強化）

- ✅ 招待受諾で IdP の検証済み email claim と招待先 email を照合（forwarded-link 耐性）
- ✅ 組織/テナント境界を IdP 側の `org_id` で workspace に記録（`org` scope）
- ✅ 招待の revoke を UI と監査で管理
- ✅ 招待 resend（再発行）を UI/API で管理
- ✅ Postgres RLS（`SET LOCAL app.tenant_id`）で org 境界を DB 層でも拘束
- ✅ 招待 policy 変更（role / maxUses / TTL / email をトークン維持のまま更新）
- ✅ org 内メンバー検索（`GET /v1/org-members`、IdP proxy + 招待フォーム email autocomplete）

### Phase 3（進行中: org 連携 UX）

- ✅ org 内メンバー検索 + 招待 email 自動入力
- org 切替 UI（未着手）
- workspace メンバー role 変更・除名・leave（未着手）

### Postgres RLS（実装済み）

- IdP `org_id` → API が `SET LOCAL app.tenant_id` を各トランザクション先頭で設定（`store.WithTenant`）
- `app.tenant_id` 未設定（NULL）のときは全行可（migration / `Unscoped`）
- 設定時は `workspaces.org_id` と一致する行のみ read/write（`app_tenant_matches`）
- 子テーブル（boards, pages, documents, …）は workspace 経由で同じ境界
- **Unscoped** 例外: 招待トークン lookup/accept、internal collab、view-token ファイル取得
- 接続ロールに `BYPASSRLS` は付与しない（Compose デフォルトロールのまま）
- アプリ層の `workspace_id + member role` チェックは従来どおり維持（二重防御）

### RLS 導入前の方針（参考）

- すべてのテーブルで `workspace_id` を境界キーとして維持
- API レイヤーでは引き続き `workspace_id + member role` を必須チェック
