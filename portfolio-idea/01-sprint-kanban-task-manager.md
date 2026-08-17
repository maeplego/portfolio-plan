# スプリント対応カンバンタスク管理

チーム開発の現場で毎日使う「課題管理」を、自作のカンバン＋スプリントボードとして実装するポートフォリオです。CRUD だけでなく、権限、状態遷移、リアルタイム更新、検索まで含めると、実務に近いフルスタック力が伝わります。

## 概要

個人・少人数チーム向けのタスク管理 Web アプリです。ボード上でカードをドラッグ＆ドロップし、スプリント単位で進捗を可視化します。GitHub Issues や Jira、Linear のミニ版として、採用担当が「この人はプロダクトの裏側を理解している」と判断しやすい題材です。

## 就職活動でのアピールポイント

- フロントエンドの状態管理、DnD、楽観的 UI 更新
- REST API 設計、トランザクション、楽観ロック
- 認証・認可（ロール、プロジェクト単位の ACL）
- リアルタイム同期（WebSocket / SSE）
- テスト、CI、デプロイまでの一連の開発プロセス

## 解決する課題

スプレッドシートやメモアプリでは、担当者・期限・優先度・進捗が散らかります。本アプリは「今スプリントで何が動いているか」を一画面で共有し、ボトルネックを可視化します。

## 想定ユーザー

- 2〜10人の開発チーム、学生プロジェクト、個人の学習管理
- 面接では「小規模スタートアップの開発チーム」を想定ユーザーとして説明すると説得力が出ます

## 主要機能

### 必須（MVP）

- ユーザー登録 / ログイン（メール＋パスワード、JWT またはセッション）
- プロジェクト作成、メンバー招待（オーナー / メンバー / 閲覧者）
- ボード（ToDo / In Progress / Done）とカード CRUD
- カードのドラッグ＆ドロップによるステータス変更
- 担当者、期限、ラベル、優先度
- スプリント作成、カードのスプリント割り当て
- コメント、アクティビティログ

### 推奨（差別化）

- リアルタイム同期（他メンバーの移動が数秒以内に反映）
- 全文検索（タイトル・本文・コメント）
- バーンダウンチャート、完了率ダッシュボード
- キーボードショートカット（`c` で新規、`/` で検索）
- GitHub Issue 連携（作成・クローズの双方向、または片方向）
- 通知（期限切れ、メンション）メールまたは Web Push

### 発展

- カスタムワークフロー（列の追加、WIP 制限）
- タイムボックス見積もり（ストーリーポイント）
- CSV エクスポート、Webhook

## 画面構成

| 画面 | 役割 |
| --- | --- |
| ログイン / サインアップ | 認証 |
| プロジェクト一覧 | 自分が所属するボードの入口 |
| ボード | カンバン本体。列とカード |
| カード詳細ドロワー | 説明、コメント、履歴 |
| スプリント計画 | バックログからスプリントへ割り当て |
| レポート | バーンダウン、担当者別負荷 |
| 設定 | メンバー、ラベル、通知 |

## API 概要

- `POST /auth/login`, `POST /auth/refresh`
- `GET/POST /projects`
- `GET/POST /projects/:id/boards/:boardId/cards`
- `PATCH /cards/:id/move`（列移動。楽観ロック用 `version` を受け取る）
- `GET/POST /projects/:id/sprints`
- `GET /projects/:id/search?q=`
- WebSocket `/ws` で `card.moved`, `comment.created` を配信

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| フロント | Next.js（App Router）、TypeScript、Tailwind CSS、dnd-kit、TanStack Query |
| バックエンド | NestJS または Go（Echo/Gin）、OpenAPI でスキーマ公開 |
| DB | PostgreSQL（カード、スプリント、ACL） |
| キャッシュ / リアルタイム | Redis（Pub/Sub）、Socket.IO または Elixir 不要の素直な WS |
| 検索 | PostgreSQL の `tsvector`、規模が伸びたら OpenSearch |
| 認証 | Auth.js または自前 JWT + refresh token、httpOnly Cookie |
| インフラ | Docker Compose（開発）、AWS ECS または Fly.io / Railway（本番） |
| CI | GitHub Actions（lint、test、e2e、イメージビルド） |
| テスト | Vitest / Jest、Playwright、API は Testcontainers で Postgres |

代替構成: フロントを React + Vite、API を FastAPI にしても同様のアピールができます。面接先の技術に寄せると効果的です。

## アーキテクチャ

ブラウザ → Next.js（BFF でも可）→ API サーバー → PostgreSQL。カード移動は API がトランザクションで列順を更新し、Redis Pub/Sub で他クライアントへ通知します。楽観的 UI を採用し、競合時はサーバーの `version` でロールバックします。

## データモデル（概要）

- `users`, `projects`, `memberships`（role）
- `boards`, `columns`, `cards`（position, version, sprint_id）
- `sprints`（start_at, end_at, goal）
- `comments`, `activities`, `labels`, `card_labels`
- インデックス: `(project_id, column_id, position)`, 全文検索用 GIN

## セキュリティ・品質

- CSRF 対策（SameSite Cookie）、XSS 対策（Markdown はサニタイズ）
- プロジェクト単位の認可チェックを全エンドポイントで実施
- レート制限、監査ログ
- マイグレーション、シードデータ、OpenAPI、README の構成図

## 実装の進め方

1. 認証とプロジェクト CRUD
2. ボードとカード、DnD
3. スプリントとレポート
4. リアルタイムと検索
5. CI/CD と本番デプロイ、デモ用シード

## 工数目安

- MVP: 2〜3 週間（個人、1日3〜4時間）
- 推奨完成度: 4〜6 週間

## 面接での話し方

「カード移動の競合をどう扱ったか」「権限モデルをどう設計したか」「リアルタイムをなぜ WebSocket にしたか」を話せるようにします。画面デモのあとに ER 図とシーケンス図を出すと、設計力の印象が強くなります。

## 公開時のチェックリスト

- デモ URL、テストアカウント、README の起動手順
- アーキテクチャ図、主要エンドポイント一覧
- テストカバレッジの数値ではなく「何を守るテストか」を書く
