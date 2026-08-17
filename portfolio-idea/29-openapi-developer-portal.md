# OpenAPI ドキュメントポータル＋モックサーバー

API ファースト開発の体験を、ポータルとして提供します。仕様を単一の真実にし、モック、例、チェンジログ、API キー発行まで付けると、プラットフォームエンジニアリングやバックエンドのコミュニケーション能力が伝わります。

## 概要

OpenAPI 3 の YAML をリポジトリまたは管理画面から登録し、見やすいリファレンス、Try it out、モック応答、差分（仕様の breaking change）を出します。Redoc や Stoplight のミニ版です。

## 就職活動でのアピールポイント

- OpenAPI を「書ける」だけでなく「運用する」
- モックサーバー（例とスキーマから応答生成）
- CI で breaking change 検出
- 開発者ポータルの IA（情報設計）
- コード生成（任意）との連携

## 解決する課題

Slack に貼られた古いエンドポイント表と、実装が乖離する問題。仕様をポータルと CI のゲートにします。

## 想定ユーザー

社内のフロントエンドと外部パートナー。デモは架空の「決済 API v1」。

## 主要機能

### 必須（MVP）

- OpenAPI YAML の登録（ファイルアップロードまたは Git 同期）
- リファレンス表示（パス、メソッド、スキーマ、例）
- バージョン（v1, v2）
- モックサーバー（`/mock/{apiId}` が example または faker で応答）
- バリデーション（リクエストをスキーマで検証して 400）

### 推奨

- Try it out（実際のモックまたは本番相当ステージング。認証ヘッダ）
- 差分ビュー（openapi-diff）
- breaking change を PR で fail させる CLI
- API キー発行（モック用）
- 検索（エンドポイント名、説明）
- コードサンプル自動生成（curl, TypeScript fetch）

### 発展

- SDK 生成（openapi-generator）の成果物ダウンロード
- Webhook の署名仕様のページ
- 複数環境のサーバー URL 切替

## 画面構成

| 画面 | 役割 |
| --- | --- |
| API カタログ | 公開 API 一覧 |
| リファレンス | 左ナビ、右ドキュメント |
| 変更履歴 | breaking / non-breaking |
| 管理 | spec アップロード |

## API 概要

- `POST /admin/specs`
- `GET /docs/:slug`（HTML）
- モック: 登録された paths をそのままマウント
- `POST /cli/diff`（2 つの spec）

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| 表示 | Scalar / Redoc / 自前（Swagger UI だけだと薄いので、ポータルの枠を自作） |
| パース | `@apidevtools/swagger-parser` または equivalent |
| モック | Prism を内包、または自前の example 優先応答 |
| 差分 | oasdiff |
| フロント | Next.js |
| DB | PostgreSQL（spec の版） |
| CLI | 23 番と思想が近い。Go または Node |
| CI | GitHub Action として diff |

## アーキテクチャ

Spec を正規化して DB に保存（元 YAML も保持）。ポータルは静的生成でも、都度レンダリングでも可。モックはゲートウェイが spec に基づき応答。CI CLI はポータルなしでも単体で使えるようにすると再利用性が高いです。

## データモデル（概要）

- `apis`（slug, title）
- `spec_versions`（semver, yaml, parsed_json, created_at）
- `api_keys`（hashed, scopes）

## セキュリティ・品質

- 管理画面の認証
- モックを公開するなら書き込み系は特に注意（副作用なし）
- spec 内の example に実シークレットを入れない lint
- YAML の巨大ファイル・アンカー爆弾へのサイズ制限

## 実装の進め方

1. 静的に 1 つの spec を綺麗に表示
2. 版管理とカタログ
3. モック
4. diff CLI と Action
5. サンプルの「良い OpenAPI」（説明、例、エラーモデル）

## 工数目安

- MVP: 2 週間
- 推奨: 3〜4 週間

## 面接での話し方

ポータルの見た目より、「仕様と実装のズレを CI で止めた」が成果です。自ら書いた OpenAPI の品質（エラー形式の統一、冪等キー）も作品の一部です。

## 公開時のチェックリスト

- サンプル spec（決済と顧客）
- モックの curl 例
- breaking change のデモ（フィールド削除）
