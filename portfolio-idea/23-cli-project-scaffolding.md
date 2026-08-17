# 開発者向け CLI スキャフォールディングツール

`create-next-app` のような、プロジェクト雛形生成 CLI です。ファイル操作、テンプレート、プラグイン、テスト可能な設計を見せられ、言語仕様と DX へのこだわりが伝わります。ツール好きな会社（開発基盤、スタートアップ）に刺さります。

## 概要

対話式（またはフラグ）で「API サーバー」「フロント」「モノレポ」などを選び、lint、テスト、CI、Docker、OpenAPI の雛形を生成します。生成後に `npm test` 相当が通ることを保証します。

## 就職活動でのアピールポイント

- CLI 設計（引数、help、色、非対話 CI モード）
- テンプレートエンジン、部分更新
- プラグイン機構
- ゴールデンテスト（生成結果のスナップショット）
- 良いデフォルト（TypeScript strict、editorconfig）

## 解決する課題

新しいサービスを作るたび、同じ ESLint / CI / Dockerfile をコピーして微妙に壊れる問題。

## 想定ユーザー

自分とチーム。デモは 30 秒で API が起動する様子。

## 主要機能

### 必須（MVP）

- `mycli create app-name`
- テンプレート: REST API（1 言語でよい）
- オプション: パッケージマネージャ、テスト有無、CI 有無
- 生成物に README、`.env.example`、Dockerfile
- `--yes` で非対話

### 推奨

- 複数テンプレート（Go API、Node API、Vite React）
- `mycli add github-actions` のように既存プロジェクトへ部分追加
- バージョンアップ（古い生成物へのパッチは難しいので、テンプレート version を埋め込む程度でも可）
- プラグイン（テンプレートを Git リポジトリから取得）
- 完了後の次のコマンド提示（DX）

### 発展

- モノレポ（pnpm workspace）
- Terraform 雛形との組み合わせ（16 番連携）
- IDE 拡張は範囲外でも可

## 画面構成

TUI（optional: Ink / Bubble Tea）があると見栄えがよいですが、まずは良いプロンプトで十分です。

## API 概要

CLI なので HTTP は不要。テンプレートリポジトリの規約（`template.json` マニフェスト）を定義します。

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| Node 生態系向け | TypeScript、citty / commander、clack prompts、giget |
| Go 向け | cobra、survey、embed.FS |
| テスト | 一時ディレクトリに生成し、lint/test を実行 |
| 配布 | npm または GitHub Releases のバイナリ |
| CI | マトリクスで各テンプレートを生成してテスト |

## アーキテクチャ

フラグ解析 → テンプレート選択 → 変数（name, module path）→ ファイルコピーと置換 → 後処理（git init は確認してから）。コアは「ファイルシステムを抽象化」し、テストでメモリ FS または temp dir。

## データモデル（概要）

マニフェスト例:

- name, description, tags
- variables（projectName, module）
- hooks（postInstall: npm i）

## セキュリティ・品質

- テンプレート内で任意シェルを無制限実行しない（許可リスト）
- 上書きする前に既存ファイルを確認
- パス traversal（zip slip 的な問題）をプラグイン取得時に防ぐ

## 実装の進め方

1. 1 テンプレートをコピー生成
2. 変数とプロンプト
3. CI で生成物テスト
4. 部分追加コマンド
5. ドキュメントとデモ GIF

## 工数目安

- MVP: 1〜2 週間
- 推奨: 3 週間（テンプレート品質が本体）

## 面接での話し方

生成物の品質（strict TS、ヘルスチェック、graceful shutdown）を「自分の標準」として語れます。ツール本体より、意見のあるデフォルトが評価されます。

## 公開時のチェックリスト

- `npx` またはバイナリでのインストール手順
- 生成から起動までの 10 行
- 対応テンプレート表
