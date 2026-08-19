# P08 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P08 content-platform |
| 対象スライス | スライス 1 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 1. 全体構成

```
pf-content-blog/          Next.js。公開 SSG 相当は後続。いまは dynamic
  lib/visibility          公開判定の正
  lib/postgres|memory     記事ストア
pf-content-shortener/    Go。GET /:code のみホットパス
  internal/target         http(s) + allowlist
  internal/code           乱数コード / カスタム slug
  internal/link           作成・解決・非同期クリック
  internal/store/postgres Redis は URL キャッシュのみ
pf-content-infra/deploy  Postgres（blog / shortener DB）+ Redis + 両サービス
```

リダイレクトを Next.js に載せない。キャッシュ可能な読み物と、列挙・フィッシング耐性が要る 302 は失敗モードが違う。

## 2. 公開判定

ブラウザや sitemap が「draft を隠す」ことは認可ではない。`isPublic(post, now)` をサーバーで評価する。公開詳細が 404 なのは、未ログインに 401 を返すと下書きの存在が分かりやすいから。

## 3. 短縮コード

`crypto/rand` で alphabet（I/l/O/0 除外）から 7 文字。連番カウンタは持たない。衝突は DB unique で 409、生成側は数回リトライ。

カスタム slug は編集者の選択なので予測され得る。数字のみは「1, 2, 3…」に見えるので拒否する。

## 4. ホットパス

1. `GET /:code`
2. Postgres（または将来 Redis ヒット後も）で Link を取る
3. inactive / expired なら 404
4. **302 を書く**
5. goroutine で `click_count` と `click_daily` を増やす

Redis は code→url のヒント。クリックを同期 INSERT すると Redis 障害が 302 の尾になる。

生 IP はテーブルに置かない。ハッシュ計算はコードに残し、集計キーには使っていない（日次件数だけ）。

## 5. 許可リスト

公開デモをオープンリダイレクトにしない。Compose 既定は `localhost,127.0.0.1`。ブログが作る短縮先は `CONTENT_PUBLIC_URL`（ホストの localhost）であり、コンテナ内部ホスト名 `blog` ではない。

## 6. 画像

`coverUrl` は文字列。シードは `/harbor.svg`。P03 のオブジェクトキーはこのスライスの契約に入れない。
