# P08 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P08 content-platform |
| 対象スライス | スライス 1 の現行ブログ / 短縮 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

## 1. 用語

| 用語 | 意味 |
| --- | --- |
| 公開記事 | `status=published` かつ `publishedAt` が現在以前 |
| 下書き | `status=draft`。公開 URL では存在しないものとして扱う |
| 短縮コード | 7 文字（カスタム時は 3–32）。記事 slug とは別空間 |
| 許可ホスト | デモで短縮してよい宛先の hostname |

## 2. 時刻

API の時刻は UTC RFC3339。DB は `timestamptz`。表示は ISO 日付で足りる（ユーザー TZ 切替は未実装）。

## 3. 読者（認証なし）

| 操作 | 仕様 |
| --- | --- |
| 記事一覧 `/` | 公開記事のみ。下書き行なし |
| 記事詳細 `/posts/{slug}` | 非公開は 404（401 にしない。存在漏洩を減らす） |
| RSS / sitemap | 公開記事のみ |
| `GET /{code}` | 302 Location。不明・無効・期限切れは 404 |
| `/admin` | ログイン画面は見える。記事 API は 401 |

## 4. 編集者

開発: 管理画面の Dev login（cookie `content_dev_sub`）または `X-Dev-User-Sub`。

| 操作 | 仕様 |
| --- | --- |
| 記事作成 | 既定は draft。slug 衝突 409 |
| 公開 / 再下書き | Publish で `publishedAt` を初回セット。Unpublish は status だけ draft に戻す（publishedAt は残してよい） |
| プレビュー `/admin/preview/{slug}` | 未ログインは 404 |
| 短縮作成 | 公開済み記事のみ。宛先は `CONTENT_PUBLIC_URL/posts/{slug}` |

## 5. 短縮の拒否

次は 400（作成しない）:

- `javascript:`, `data:`, `file:`, 非 http(s)
- 許可リストに無いホスト
- URL 内 userinfo
- 数字のみのカスタム slug、予約語（`health`, `ready`, `v1` 等）

## 6. エラー

短縮とブログ API の本文:

```json
{ "error": { "code": "host_not_allowed", "message": "destination host is not on the demo allowlist" } }
```

未認証の管理操作は 401。他人の短縮リソースは 403。
