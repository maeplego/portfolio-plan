# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

ユーザーと Relying Party（RP）から見た振る舞い。テーブル名や鍵の置き場所は [03-design.md](03-design.md)。

## 1. ログインと同意（Consent）

未ログインで `GET /authorize` すると IdP のログイン画面になる。成功後に Consent。利用者が拒否すると RP の `redirect_uri` に OIDC の error を返す。初期 scope は `openid`, `profile`, `email`, `offline_access`。

登録はメールとパスワード。メール検証メールは送らない（未実装）。未検証アカウントでもログインできる。ID Token の `email_verified` は常に `false`。

## 2. トークン

認可コードは短命で単回使用。PKCE は S256。refresh は回転する。再利用を検出するとその family 全体を失効する（FR-04 / FR-05）。

ID Token（RS256）の最低クレーム: `iss`, `sub`, `aud`, `exp`, `iat`, `nonce`, `sid`。scope に応じて `email` / `email_verified` / `name`。RP は利用者の主キーとして `sub` を使う（FR-06）。email を主キーにしない。

アクセストークンは opaque。クレームは `GET /userinfo` で取る。

`redirect_uri` はクライアント登録値と完全一致のみ（FR-01）。部分一致やオープンリダイレクトは拒否する。

## 3. ログアウト

- **RP-Initiated:** `end_session_endpoint`。登録済みの `post_logout_redirect_uri` だけを戻し先にする。
- **Front-Channel:** RP が iframe でログアウト URL を読む。`iss` と `sid` を付ける。
- **Back-Channel:** IdP が RP へ `logout_token` JWT を POST。`jti` の再利用は拒否する。

Compose の sample-rp と sample-rp-b で、一方からログアウトするともう一方のセッションも終わることを確認できる。

## 4. 管理

管理者は `IDENTITY_ADMIN_TOKEN` でクライアント CRUD、ユーザー無効化、監査一覧を行う。client secret の平文は作成時または rotate 時の応答に一度だけ出す。

管理 UI は Next.js（`apps/admin`）。接続確認用の最小 RP は `apps/sample-rp`。

## 5. 他製品との関係

他アプリはパスワードを持たず、OIDC 認可コード + PKCE でこの IdP に接続する。単体デモでは各製品の開発ヘッダでも動く。連携時の RP 例:

- メディア基盤 [pf-media](https://github.com/maeplego/pf-media)
- チーム作業場所 [pf-workspace](https://github.com/maeplego/pf-workspace)
- 予約カレンダー [pf-calendar](https://github.com/maeplego/pf-calendar)

アプリ固有 scope（例: `calendar.book`）は未追加。

## 6. エラー

redirect 不一致、PKCE 失敗、code 再利用、無効 client は OIDC の error または HTTP 4xx。詳細はテストと [05-api.md](05-api.md)。`/token` に CORS `*` は付けない（FR-07）。
