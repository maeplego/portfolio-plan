# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | コンテンツ基盤（GitHub: `pf-content-blog`、`pf-content-shortener`、Compose 束ね役 `pf-content-infra`） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

読者と編集者、公開 URL と短縮 302 から見た振る舞い。ホットパスの内部は [03-design.md](03-design.md)。

## 1. 目的

技術記事の下書きと公開を分け、シェア用の短い URL を同じ製品として扱う。公開サイトは匿名、管理だけ開発ログイン。学習用であり、本番 CMS や商用短縮の置き換えではない。

## 2. 含む / 含まない

含む: Markdown CMS、下書き / 公開、公開 URL の 404、編集者プレビュー、Draft Mode、OG 画像（公開題名）、RSS / sitemap、短縮作成と 302、非同期クリック、日次グラフ、宛先ホスト許可リスト、記事 HTML の `javascript:` 無効化。

含まない: Tailwind + MDX、本番 OIDC（`pf-identity`）、メディア基盤（`pf-media`）の実パイプライン、コメント、全文検索、k6 の数値公表、マルチテナント独自ドメイン。

## 3. 用語

| 用語 | 意味 |
| --- | --- |
| 公開記事 | `status=published` かつ `publishedAt` が現在以前 |
| 下書き | `status=draft`。未ログインの公開 URL では 404。Draft Mode + 編集者 cookie のときだけ同じ URL で見える |
| 短縮コード | 7 文字（カスタム時は 3–32）。記事 slug とは別空間 |
| 許可ホスト | デモで短縮してよい宛先の hostname |
| Draft Mode | Next.js の下書きプレビュー。cookie だけでは匿名読者に下書きを出さない |
| OG 画像 | `/posts/{slug}/opengraph-image`。公開記事の題名。下書きの題は出さない |

## 4. 時刻

API の時刻は UTC RFC3339。DB は `timestamptz`。表示は ISO 日付で足りる（ユーザー TZ 切替は未実装）。

## 5. 読者（認証なし）

| 操作 | 仕様 |
| --- | --- |
| 記事一覧 `/` | 公開記事のみ。下書き行なし |
| 記事詳細 `/posts/{slug}` | 非公開は 404（401 にしない）。Draft Mode かつ編集者なら下書きを表示しバナーを出す |
| OG `/posts/{slug}/opengraph-image` | 公開記事の題名。下書きの題は出さない |
| RSS / sitemap | 公開記事のみ |
| `GET /{code}` | 302 Location。不明・無効・期限切れは 404 |
| `/admin` | ログイン画面は見える。記事 API は 401 |

## 6. 編集者

開発: 管理画面の Dev login（cookie `content_dev_sub`）または `X-Dev-User-Sub`。

| 操作 | 仕様 |
| --- | --- |
| 記事作成 | 既定は draft。slug 衝突 409 |
| 公開 / 再下書き | Publish で `publishedAt` を初回セット。Unpublish は status だけ draft に戻す（publishedAt は残してよい） |
| プレビュー `/admin/preview/{slug}` | 未ログインは 404 |
| Draft Mode `POST /api/draft` | 編集者のみ enable。cookie だけでは下書きを公開しない |
| 短縮作成 | 公開済み記事のみ。宛先は `CONTENT_PUBLIC_URL/posts/{slug}` |
| 日次グラフ | 管理画面。`GET /v1/links/{id}/stats` の `daily` をバー表示 |

記事本文の Markdown は `<` をエスケープしたうえで、リンクと画像の URL を http(s) / mailto / `#` / 相対パスだけにする。`javascript:` はテキストとして残し、`href` にしない。

## 7. 短縮の拒否

次は 400（作成しない）:

- `javascript:`, `data:`, `file:`, 非 http(s)
- 許可リストに無いホスト
- URL 内 userinfo
- 数字のみのカスタム slug、予約語（`health`, `ready`, `v1` 等）

## 8. エラー

短縮とブログ API の本文:

```json
{ "error": { "code": "host_not_allowed", "message": "destination host is not on the demo allowlist" } }
```

未認証の管理操作は 401。他人の短縮リソースは 403。

## 9. 受け入れ

1. 公開記事 `why-redirect-is-not-nextjs` が読める。下書き slug の公開 URL は 404。
2. 編集ログイン後にプレビューでき、Publish すると公開される。Draft Mode で公開 URL にバナー付き下書きが見える。
3. 公開記事の OG 画像が題名を出す。下書き題は出さない。
4. 許可ホスト向け短縮が 201、`javascript:` と許可外ホストが 400。`GET /:code` が 302。
5. 管理画面の日次バーが `daily: [{ date, count }]` を表示する（クリックは非同期なので数秒遅れ可）。
