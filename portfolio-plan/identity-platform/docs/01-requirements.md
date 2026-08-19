# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

各アプリが独自のパスワードを持つと、アカウントが分裂し、ログアウトや無効化の正本が無くなる。認証基盤はポートフォリオ全体の **唯一のアカウント発行点** にする。Relying Party（RP）は OIDC 認可コード + PKCE だけを使い、アプリ側にパスワードを置かない。

学習用の IdP であり、商用 IdP の置き換えではない。常時公開の本番テナントは持たない。

## 2. 含む

- メールとパスワードによるユーザー登録、サーバーサイドセッション（Cookie）でのログイン
- `GET /authorize`、Consent、認可コード発行（ハッシュ保存、単回使用、短命）
- `POST /token`（`authorization_code` + PKCE S256、refresh の回転）
- ID Token（RS256）、JWKS、OIDC Discovery
- 管理 UI（クライアント CRUD、ユーザー無効化、監査）
- 接続確認用 sample-rp（Compose では sample-rp-b も）
- RP-Initiated Logout、Front-Channel Logout、Back-Channel Logout

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| メール検証と本格的なアカウント復旧 | 未実装。未検証でもログインできる。`email_verified` は常に `false` |
| ソーシャルログイン仲介 | 範囲外 |
| SAML、パスキー、PAR、CIBA、implicit flow | 範囲外。暗号の自前実装もしない |
| アプリ固有 scope（例: `calendar.book`） | 利用側が必要になったら追加する。初期は `openid` / `profile` / `email` / `offline_access` |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| エンドユーザー | 登録し Consent する人 | パスワード + HttpOnly Cookie |
| RP | 各 `pf-*` と sample-rp | public は PKCE 必須・secret 無し。confidential は secret |
| 管理者 | クライアント登録とユーザー無効化 | `IDENTITY_ADMIN_TOKEN` |

## 5. 前提

- 単体デモは Compose（Postgres、IdP、admin、sample-rp）。他製品が落ちていても IdP 単体は動く
- 鍵はリポジトリに PEM を置かない。開発用は Compose の secret
- パスワードは Argon2id。認可コード・refresh・client secret はハッシュ保存
- アクセストークンは opaque。クレームは UserInfo で取る
- 他製品は開発中にヘッダ認証でも動いてよい。連携時の発行点はこの IdP

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | `redirect_uri` は登録値と完全一致。クエリ追加やポート違いも別エントリ | オープンリダイレクト |
| FR-02 | public クライアントは secret 無し・PKCE S256 必須 | モバイル / PWA。secret をバイナリに埋めない |
| FR-03 | 認可コード、refresh、client secret はハッシュ保存。平文 secret は発行時または rotate 時だけ | 漏洩時の被害を小さくする |
| FR-04 | 同じ認可コードの二回交換は失敗する | 認可コード横取り |
| FR-05 | refresh の再利用を検出したら family 全体を無効化する | 盗難検出 |
| FR-06 | RP は利用者の主キーに `sub` を使う。email は主キーにしない | メール変更 |
| FR-07 | token エンドポイントに CORS `*` を付けない | ブラウザ直交換を誘わない |
| FR-08 | Consent 拒否時は RP の `redirect_uri` に OIDC の error を返す | 仕様どおりの失敗 |
| FR-09 | ログアウトは登録済み `post_logout_redirect_uri` だけを戻し先にする。Front-Channel は `iss` と `sid`。Back-Channel の `logout_token` は `jti` 再利用を拒否する | セッション終了の契約 |
| FR-10 | 管理者はクライアント CRUD、ユーザー無効化、監査一覧ができる | 運用の最小口 |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | README に学習用であることと既知の非実装を書く | 本番誤用 |
| NFR-02 | リポジトリに PEM を置かない | 鍵の漏洩 |
| NFR-03 | ログインの brute-force は IP + アカウントでレート制限する | パスワード推測 |
| NFR-04 | `go test ./...`（`apps/server`）が認可コード横取りと refresh 再利用を回帰する | 仕様の正 |

## 8. 受け入れ

1. sample-rp でログインし UserInfo が出る
2. 改ざんした `redirect_uri` が拒否される
3. 同じ認可コードの二回交換が失敗する
4. 一方の RP からログアウトするともう一方のセッションも終わる（Compose の sample-rp-b）
5. refresh 再利用で family が無効化される
