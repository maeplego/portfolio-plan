# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | コンテンツ基盤（GitHub: `pf-content-blog`、`pf-content-shortener`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

記法は Mermaid。ユースケースは UML 楕円の代わりにフローで書く。Kubernetes の content 構成は Compose の任意の連携デモであり、開発者ポータルは載せない。

## 1. ユースケース

```mermaid
flowchart LR
  subgraph actors [アクター]
    Reader[読者]
    Editor[編集者]
  end
  subgraph uc [記事と短縮]
    UC1[公開記事を読む]
    UC2[下書きをプレビューする]
    UC3[公開する]
    UC4[短縮 URL を作る]
    UC5[短縮を踏む]
    UC6[日次クリックを見る]
  end
  Reader --> UC1
  Reader --> UC5
  Editor --> UC2
  Editor --> UC3
  Editor --> UC4
  Editor --> UC6
  UC3 --> UC4
  UC4 --> UC5
  UC5 --> UC6
```

## 2. 画面遷移

```mermaid
flowchart TB
  Home[公開一覧 /]
  Post[記事 /posts/slug]
  OG[OG /posts/slug/opengraph-image]
  Demo[デモ /demo]
  Admin[管理 /admin]
  Preview[プレビュー /admin/preview/slug]
  Home --> Post
  Post --> OG
  Home --> Demo
  Home --> Admin
  Admin --> Preview
  Admin -->|Publish| Post
  Admin -->|Draft Mode| Post
  Admin -->|shorten| Short[短縮 302]
  Short --> Post
  Draft404[下書き公開 URL 404]
```

## 3. 短縮ヒット（成功）

```mermaid
sequenceDiagram
  actor Reader
  participant Go as shortener
  participant Cache as Redis
  participant DB as Postgres
  Reader->>Go: GET /:code
  Go->>DB: ByCode
  DB-->>Go: url
  Go-->>Reader: 302 Location
  Note over Go,DB: クリックは goroutine。生 IP は保存しない
  Go->>DB: click_count + click_daily
```

## 4. 下書きを公開 URL に出さない

```mermaid
sequenceDiagram
  actor Reader
  actor Editor
  participant Blog
  Reader->>Blog: GET /posts/notes-on-scheduled-posts
  Blog-->>Reader: 404
  Editor->>Blog: Dev login
  Editor->>Blog: GET /admin/preview/notes-on-scheduled-posts
  Blog-->>Editor: 200 Markdown
  Editor->>Blog: POST /api/draft
  Editor->>Blog: GET /posts/notes-on-scheduled-posts
  Blog-->>Editor: 200 + Draft Mode バナー
```

## 5. 記事状態

```mermaid
stateDiagram-v2
  [*] --> draft: Create
  draft --> published: Publish
  published --> draft: Unpublish
  published --> [*]
```

予約投稿ワーカーは未実装。未来の `publishedAt` は `isPublic` が false のまま。

## 6. ER（論理）

```mermaid
erDiagram
  posts {
    text id PK
    text slug UK
    text status
    timestamptz published_at
  }
  links {
    text id PK
    text code UK
    text url
    bigint click_count
  }
  click_daily {
    text link_id
    date day
    bigint count
  }
  links ||--o{ click_daily : daily
```

記事と短縮に物理 FK は無い。紐づけは管理操作で作る URL 一致。
