# コードレビュー支援ツール

Pull Request の差分閲覧、コメント、チェックリスト、AI 補助（任意）を持つ小さなレビュー基盤です。Git 操作と Web UI、権限、Markdown を扱うため、開発者向けプロダクトの設計力が伝わります。

## 概要

GitHub を完全再現する必要はありません。ローカル Git リポジトリまたは GitHub API から PR 相当の差分を取り込み、レビューコメントをスレッド表示します。「開発者体験」をテーマにしたポートフォリオになります。

## 就職活動でのアピールポイント

- Git オブジェクト / diff の理解、または GitHub API 連携
- 行単位コメントのアンカー（ファイルパス＋行番号＋コミット SHA）
- レビュー状態（Approve / Request changes）
- 権限と監査
- パフォーマンス（大きな diff の遅延レンダリング）

## 解決する課題

学習用リポジトリで GitHub を使わずにレビュー練習したい、または社内 Git サーバ向けの薄い UI が欲しい、という場面を想定します。

## 想定ユーザー

学生チーム、社内 GitLab をシンプルにしたい小チーム。デモは公開サンプル PR を 2〜3 件。

## 主要機能

### 必須（MVP）

- リポジトリ登録（GitHub URL + PAT、または `git clone` したローカルパスをサーバーが読む）
- PR 一覧（open / merged）
- ファイル差分ビュー（unified / split）
- 行コメント、スレッド返信
- レビュー提出（コメントのみ / 承認）
- Markdown とコードフェンス

### 推奨

- チェックリストテンプレ（「テスト追加したか」等）
- 変更ファイルのフィルタ、ファイルツリー
- CI ステータスの表示（GitHub Checks API、または自前 webhook）
- レビュー担当のアサイン、レビュアー自動提案（変更ディレクトリの CODEOWNERS 簡易版）
- キーボードで hunk 移動

### 発展

- LLM による要約とリスク指摘（コードはサーバー経由、保持ポリシーを明記）
- ブラウザ内での提案（suggestion）をコメントとして保存
- マージボタン（実際の merge は GitHub API）

## 画面構成

| 画面 | 役割 |
| --- | --- |
| リポジトリ一覧 | 登録済み repo |
| PR 一覧 | タイトル、著者、レビュー状態 |
| 差分ビュー | 左ツリー、右 diff、コメント |
| 設定 | PAT、Webhook、テンプレ |

## API 概要

- `GET /repos/:id/pulls`
- `GET /pulls/:id/files`
- `POST /pulls/:id/comments`（path, line, side, sha）
- `POST /pulls/:id/reviews`
- GitHub 連携時は既存 REST/GraphQL を BFF でラップ

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| フロント | Next.js、TypeScript、Monaco または Shiki + 自前行レンダラ、react-diff-view |
| バックエンド | NestJS / Go |
| Git 連携 | GitHub API（Octokit）が実装安定。自前で `git` コマンドを叩く場合はサンドボックス必須 |
| DB | PostgreSQL（コメント、レビュー） |
| キャッシュ | Redis（diff の一時キャッシュ） |
| インフラ | Docker、GitHub Actions |

自前で git バイナリを実行する場合、パストラバーサルとコマンドインジェクション対策をREADMEで強調します。ポートフォリオとしては GitHub API 方式の方が安全で完成しやすいです。

## アーキテクチャ

BFF が GitHub から files API を取得し、コメントは自前 DB に保存します。行ずれ問題（後続コミットで行番号が変わる）は「SHA に紐づける」と明記し、簡易実装では最新 SHA のみサポートでも構いません。その制限を自分で語れることが大切です。

## データモデル（概要）

- `repositories`, `pull_requests`（外部 ID）
- `review_comments`（commit_sha, path, line, body）
- `reviews`（state）
- `checklist_templates`, `checklist_items`

## セキュリティ・品質

- PAT は暗号化して保存、ログに出さない
- XSS（コメント Markdown）
- リポジトリごとにアクセス権
- 大きな diff はファイル単位遅延ロード、上限サイズで切る

## 実装の進め方

1. GitHub PAT で PR 一覧・diff 表示
2. コメントとレビュー
3. チェックリストとアサイン
4. 大きな PR の性能
5. 制限事項を README に書く

## 工数目安

- MVP: 2 週間
- 推奨: 3〜4 週間

## 面接での話し方

「行コメントをどのキーで一意にしたか」「巨大 diff で DOM が爆発しない工夫」が技術質問になりやすいです。Git の 3-way merge まで実装する必要はありません。

## 公開時のチェックリスト

- 公開デモでは読み取り専用の Fine-grained PAT と公開リポジトリのみ
- サンプル PR へのディープリンク
- 既知の制限（force-push 後のコメントずれ等）
