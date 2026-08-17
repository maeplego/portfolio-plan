# GraphQL BFF（Backend for Frontend）

モバイルと Web で必要な形が違う API を、BFF で集約する題材です。N+1、DataLoader、スキーマ設計、キャッシュを語れ、フロントとバックの橋渡し役として強いです。

## 概要

下位に REST のマイクロサービス（またはモック）を置き、GraphQL で「画面単位のクエリ」を提供します。商品詳細、カート、ユーザーを 1 リクエストで取り、オーバーフェッチを避けます。

## 就職活動でのアピールポイント

- GraphQL スキーマ設計（グラフ、命名、null 可能性）
- DataLoader による N+1 解消
- 認証コンテキストの伝播
- エラー処理（部分成功）
- フロントのコロケーション（Relay 的な fragment は任意）

## 解決する課題

商品画面が REST を 5 回叩いて遅い、モバイルは帯域を惜しみたい。BFF が集約と整形を担います。

## 想定ユーザー

Web と簡易モバイル Web。デモは商品一覧→詳細（レビュー、在庫、おすすめ）。

## 主要機能

### 必須（MVP）

- スキーマ: User, Product, Review, Cart
- クエリ: 商品詳細（在庫とレビューをネスト）
- ミューテーション: カート追加、ログイン
- DataLoader でレビューと在庫のバッチ取得
- GraphQL Playground / Apollo Sandbox
- 下位 REST は自作 2〜3 本、または json-server ではなくちゃんと遅延を入れて効果を見せる

### 推奨

- persisted queries またはクエリ深度制限
- レート制限、複雑度（query cost）
- キャッシュ（CDN は GET の persisted、または entity cache）
- DataLoader なし / ありのトレース比較を README に書く
- フロントは Apollo Client または urql、生成型（GraphQL Code Generator）

### 発展

- Federation は個人開発では過剰。やらない理由を書けるとよい
- Subscription で在庫更新（12 番や 06 番と接続）

## 画面構成

| 画面 | 役割 |
| --- | --- |
| カタログ | 一覧クエリ |
| PDP | 詳細 1 クエリ |
| カート | mutation |
| Sandbox | スキーマ探索（デモ用） |

## API 概要

- `POST /graphql`
- 下位: `GET /catalog/products/:id`, `GET /inventory/:id`, `GET /reviews?productId=`

BFF がトークンを受け、下位へは内部ヘッダでユーザー ID を渡します。

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| BFF | NestJS + Apollo、または Yoga / Pothos（型安全） |
| 言語 | TypeScript |
| フロント | Next.js |
| 下位 | 小さな Go/Node REST |
| 観測 | 18 番と同様にトレースすると BFF の価値が見える |
| インフラ | Docker Compose |

## アーキテクチャ

Client → BFF (GraphQL) → REST services。Resolver は薄く、DataLoader がバッチキーを 1 tick でまとめる。タイムアウトとサーキットは推奨。

## スキーマ概要

- `Product { id, name, price, inventory, reviews, similar }`
- `Inventory { sku, quantity, updatedAt }`
- `Review { id, rating, body, author }`
- Mutation `addToCart(input): Cart`

ID は Global ID（`Product:123`）にすると Relay との相性を語れます。必須ではありません。

## セキュリティ・品質

- イントロスペクションは本番オフ、デモはオン
- クエリ深度・コスト上限（DoS）
- 認可は Resolver ごと（他ユーザーのカートを見られない）
- ファイルアップロードは最初は除外

## 実装の進め方

1. 下位 REST と素朴な GraphQL（N+1 あり）
2. DataLoader 導入とベンチ
3. 認証とカート
4. フロント接続と型生成
5. コスト制限とドキュメント

## 工数目安

- MVP: 2 週間
- 推奨: 3〜4 週間

## 面接での話し方

「GraphQL を全部に使わない。外部公開は REST、画面集約は BFF」という使い分けができると良いです。N+1 を GraphiQL のトレースで見せるデモが効果的です。

## 公開時のチェックリスト

- スキーマ SDL
- DataLoader 前後のリクエスト数比較
- サンプルクエリ集
