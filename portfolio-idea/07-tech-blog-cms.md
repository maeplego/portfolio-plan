# 技術ブログ CMS（自作ヘッドレス＋フロント）

エンジニアの定番ですが、Markdown を Git に置くだけにせず、CMS・プレビュー・RSS・OG 画像・全文検索まで作ると「フロントの本番品質」が伝わります。コンテンツ自体が自己紹介になる二重のメリットがあります。

## 概要

管理画面で記事を書き、公開するとブログ側に反映されます。MDX 対応、シンタックスハイライト、目次、関連記事を備えます。ポートフォリオサイトのブログ欄としても使えます。

## 就職活動でのアピールポイント

- Next.js の SSG / ISR / Draft Mode
- ヘッドレス CMS 設計、プレビュー
- 画像最適化、Core Web Vitals を意識した実装
- SEO（メタ、構造化データ、sitemap、RSS）
- アクセシビリティ（見出し階層、キーボード）

## 解決する課題

Git ベースだと非エンジニアが書けず、WordPress だと過剰です。自分の記事公開に特化した軽量 CMS を自作します。

## 想定ユーザー

自分自身（技術発信）と、将来的には小さな開発チームのテックブログ。

## 主要機能

### 必須（MVP）

- 記事 CRUD（タイトル、スラッグ、本文 Markdown、タグ、公開日時）
- 下書きと公開、予約投稿
- 記事一覧・詳細、タグアーカイブ
- RSS、sitemap.xml
- コードブロックのハイライト

### 推奨

- Draft Mode（未公開をプレビュー）
- 自動 OG 画像生成（タイトル入り）
- 目次、見出しリンク、コピーボタン
- 全文検索
- いいね、または View カウント（プライバシーに配慮し IP ハッシュ）
- 画像アップロードと `next/image`

### 発展

- MDX（記事内に React コンポーネント）
- シリーズ（連載）
- ニュースレター登録（外部メール配信）

## 画面構成

| 画面 | 役割 |
| --- | --- |
| 公開ブログ | 高速な読み物 |
| 管理ログイン | 自分だけ |
| 記事エディタ | 分割プレビュー |
| メディア | 画像管理 |
| 分析（簡易） | PV、人気記事 |

## API 概要

公開側は主に SSG なので API は管理用です。

- `GET/POST /admin/posts`
- `POST /admin/preview`
- `POST /admin/media`
- 公開 API が必要なら `GET /api/posts` をキャッシュ付きで

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| 公開フロント | Next.js App Router、TypeScript、Tailwind、shadcn/ui |
| CMS | 同じ Next.js の Route Handler、または別 API |
| DB | PostgreSQL または SQLite（Turso）でも可 |
| コンテンツ | MDX、rehype-pretty-code、contentlayer 相当は自前でも可 |
| ホスティング | Vercel または Cloudflare Pages |
| 画像 | S3 / R2、または Vercel Blob |

## アーキテクチャ

公開リクエストは CDN キャッシュ。更新時は ISR revalidate または on-demand revalidate。管理画面のみ認証必須。OG 画像は Edge で SVG → PNG でも、ビルド時生成でもよいです。

## データモデル（概要）

- `posts`（slug unique, status, published_at, body）
- `tags`, `post_tags`
- `media`
- `post_stats`（views）

## セキュリティ・品質

- 管理画面は強力なパスワード、可能なら Passkey / OAuth（GitHub）のみ
- 公開コメントはスパムリスクが高いので、最初は付けないか GitHub Discussions に逃す
- Lighthouse の Accessibility / Performance を README に記載（数値は盛らない）

## 実装の進め方

1. Markdown 記事の静的生成
2. DB 駆動の CMS
3. プレビューと OG
4. 検索と RSS
5. 実際に技術記事を 3 本以上書く（中身が採用担当に読まれる）

## 工数目安

- 静的ブログのみ: 数日
- CMS 込み推奨: 2〜3 週間

## 面接での話し方

「なぜ SSG にしたか」「下書きプレビューをどう漏洩させないか」が定番です。記事テーマは、作った他ポートフォリオの設計判断を書くと一貫します。

## 公開時のチェックリスト

- 独自ドメイン、HTTPS
- サンプル記事 3 本（設計、トラブルシュート、学び）
- `robots.txt` と OGP の確認
