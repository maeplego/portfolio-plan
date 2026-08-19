# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | コンテンツ基盤（ブログ [pf-content-blog](https://github.com/maeplego/pf-content-blog)、短縮 [pf-content-shortener](https://github.com/maeplego/pf-content-shortener)、Compose 束ね役 [pf-content-infra](https://github.com/maeplego/pf-content-infra)） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

技術記事はポートフォリオそのものになる。Git に Markdown を置くだけでは下書きと公開の境界が無い。一方で短縮リンクの 302 をブログの Node プロセスに載せると、キャッシュ向けの公開サイトと、悪用耐性が要るホットパスが混ざる。

ブログ CMS と短縮を同じ製品にまとめ、プロセスだけ分ける。学習用であり、商用 CMS や Bitly の置き換えではない。

## 2. 含む

- Markdown 記事（架空コンテンツ。実在 PII なし）
- 下書きと公開。公開 URL では下書きが 404
- 編集者だけが下書きをプレビューできる。Draft Mode（cookie だけでは匿名読者に下書きを出さない）
- 公開記事の OG 画像（題名。下書きの題は出さない）
- RSS と sitemap（公開記事のみ）
- 短縮の作成 API と `GET /:code` の 302。クリック件数はリダイレクトを待たない
- 管理画面の日次グラフ（`daily`）
- デモ用の宛先ホスト許可リスト。`javascript:` 拒否
- 単体 Compose（`pf-content-infra`）でブログ + 短縮が動く
- 画像はローカル `/public` または URL 文字列（メディア基盤 [pf-media](https://github.com/maeplego/pf-media) は任意）

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| Tailwind + MDX | 未実装。Markdown CMS で足りる |
| 認証基盤の本番 OIDC | 開発ヘッダ / cookie で開始 |
| メディア基盤の実パイプライン | ソフト依存 |
| コメント、ニュースレター、全文検索 | スパムと範囲 |
| マルチテナント独自ドメイン短縮 | 範囲外 |
| 生 IP の長期保存 | プライバシー |
| overlay E への開発者ポータル | Compose が単体デモの正。K8s は任意 |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| 読者 | 公開記事を読む。短縮を踏む | なし |
| 編集者 | 下書き・公開・短縮作成 | `CONTENT_DEV_AUTH` + cookie / `X-Dev-User-Sub` |
| システム（短縮） | 302 と非同期クリック | — |

## 5. 前提

- ID は ULID。DB 時刻は `timestamptz`（UTC）
- 記事スラッグと短縮コードの名前空間は混ぜない
- ブログは Next.js、短縮は Go、Compose は `pf-content-infra`
- シードは架空の Harbor Press。記事 `why-redirect-is-not-nextjs` など

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 公開一覧・詳細は `published` かつ `published_at <= now` だけ | 下書き漏洩 |
| FR-02 | 下書きの公開 slug は 404。プレビューは編集者のみ | 非公開のまま見られる |
| FR-03 | 記事 CRUD（title, slug, Markdown, tags, 公開日時） | CMS の本体 |
| FR-04 | RSS と sitemap は公開記事のみ | SEO に下書きを載せない |
| FR-05 | 短縮コードは予測困難。連番禁止。数字のみのカスタム slug も禁止 | 列挙 |
| FR-06 | 宛先は http(s) のみ。許可ホスト以外は拒否 | オープンリダイレクト / フィッシング |
| FR-07 | `GET /:code` は 302。クリック記録は応答後 | ホットパス |
| FR-08 | 管理画面は robots で拒否 | 検索エンジンに載せない |
| FR-09 | 公開記事の短縮 URL を管理から作れる | 統合 UX |
| FR-10 | Draft Mode は編集者のみ enable。cookie だけでは下書きを公開しない | プレビューと公開の境界 |
| FR-11 | 公開記事の OG 画像は題名を出す。下書きの題は出さない | SNS カードからの漏洩 |
| FR-12 | 短縮の日次クリックを管理画面のグラフで見られる | シェア効果の確認 |
| FR-13 | 公開 Markdown は raw HTML を出さず、`javascript:` / `data:` をリンクにしない | XSS |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | 短縮の純論理と httptest は DB なしで緑 | CI |
| NFR-02 | 生 IP をテーブルに残さない | プライバシー |
| NFR-03 | README に学習用である旨 | 本番誤用 |
| NFR-04 | Compose 必須。overlay E は任意の連携デモ | 12 GB |

## 8. 受け入れ

1. 公開記事 `why-redirect-is-not-nextjs` が読める
2. 下書き `notes-on-scheduled-posts` の公開 URL が 404
3. 編集ログイン後にプレビューでき、Publish すると公開される。Draft Mode でバナーが出る
4. 公開記事の OG 画像が題名を含む。下書き slug の OG は題を出さない
5. 許可ホスト向け短縮が 201、`javascript:` と許可外ホストが 400
6. `GET /:code` が 302 で記事 URL へ。管理の日次グラフが `daily` を表示する
7. `docker compose up`（`pf-content-infra/deploy`）で上記が再現できる
