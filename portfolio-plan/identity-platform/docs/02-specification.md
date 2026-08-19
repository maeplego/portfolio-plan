# P01 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | 現行 OIDC。メール検証は未実装と書く |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

## 1. ログインと Consent

未ログインで `/authorize` するとログイン画面。成功後 Consent。拒否は RP に error を返す。scope 初期セットは `openid`, `profile`, `email`, `offline_access`。

## 2. トークン

認可コードは短命・単回。PKCE S256。refresh は回転。再利用検出で family 失効。ID Token クレーム最低: `iss`, `sub`, `aud`, `exp`, `iat`, `nonce`, `sid`、scope に応じた `email` / `email_verified` / `name`。未検証メールは `email_verified=false`（検証自体が未実装）。

アクセストークンは opaque。`/userinfo` で取る。

## 3. ログアウト

RP-Initiated: `end_session_endpoint` + 登録済み `post_logout_redirect_uri`。Front-Channel は iframe（`iss` と `sid`）。Back-Channel は `logout_token` JWT を RP へ POST。`jti` 再利用は拒否。

## 4. 管理

管理者トークンでクライアント CRUD、secret は作成時または rotate 時だけ平文。ユーザー無効化。監査一覧。

## 5. エラー

redirect 不一致、PKCE 失敗、code 再利用、無効 client は OIDC の error または 4xx。詳細はテストと [05-api.md](05-api.md)。
