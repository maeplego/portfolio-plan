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

| リポジトリ | 役割 | 元アイデア |
| --- | --- | --- |
| `pf-workspace-web` | シェル（左ナビ）、ボード、Wiki ツリー、チャット UI、エディタ | すべて |
| `pf-workspace-api` | ワークスペース、権限、カンバン、Wiki メタデータ、検索インデックス更新、通知設定 | 01, 02 |
| `pf-workspace-collab` | Yjs / Hocuspocus。文書と Wiki 本文の CRDT 同期 | 26, 02 の本文 |
| `pf-workspace-chat` | WebSocket、メッセージ永続化、presence、未読 | 12 |
| `pf-workspace-infra` | Compose（api, collab, chat, redis, postgres, web） |  |

モノレポにしない理由: collab と chat は sticky 接続でスケール単位が違う。api をデプロイしても編集中セッションを落としたくない。

モノレポでもよかった点（採用しなかった）: 共有 TypeScript 型。代わりに OpenAPI から web の型を生成する。

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

1. ワークスペース CRUD、メンバー、OIDC ログイン（web + api）
2. カンバン MVP（DnD、カード詳細）— 画面デモが最も早い
3. Wiki ツリー + 単一ユーザー Markdown（まだ CRDT なし）
4. collab を Wiki 本文と独立ドキュメントに接続。2 ブラウザデモ
5. チャット（履歴 REST + WS + seq）
6. 横断検索、メンション、添付（P03）
7. スプリントバーンダウン、Wiki 履歴 diff

## 実装上の注意点

- guest は公開リンク相当。ボードのカード移動を禁止するなど、ロールをサーバーで強制
- チャットの `seq` はチャンネル内単調増加。再接続は `afterSeq`
- typing イベントは永続化しない。debounce する
- 巨大 diff や巨大 Y.Doc のサイズ上限
- Markdown プレビューの XSS。共同編集でもサニタイズは表示側
- IME と Yjs の既知問題を README に書く
- 検索から権限外ページを出さない（アイデア 02 の核心）
- リアルタイムを 3 種類（カード移動、CRDT、チャット）混ぜた単一ソケットにしない。プロトコルが腐る

## 他プロジェクトとの契約

- P01: OIDC。`sub` を workspace member に紐づける
- P03: 添付 `purpose=wiki|chat`
- P11: 完成後、この構成を CLI テンプレートの「modular workspace」の参考にする。テンプレート化は P11 の仕事
- P05: 将来ワークスペースから面談枠を取るが、P04 MVP の範囲外

## デモ

- 2 ブラウザでカード移動と同時編集とチャットが同時に見える（落ちても他が生きることも見せる）
- guest リンクで Wiki は読めてボードは触れない

## 非目標

- 音声・ビデオ
- E2EE チャット
- GitHub 双方向同期（カンバンの発展。P11 の code-review と混ぜない）
