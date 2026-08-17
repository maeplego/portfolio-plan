# P01 identity-platform — 設計方針

## この資料の使い方

実装チャットでは `identity-platform/AGENTS.md` に列挙されたファイルを先に読む。

他アプリを IdP に繋ぐ作業では、利用側プロジェクトの `DESIGN.md` も渡す。

## 対応アイデア

- 14 OAuth 2.0 / OIDC 認証基盤

## 目的

ポートフォリオ全体の **唯一のアカウント発行点** にする。各製品はパスワードを持たず、OIDC 認可コード + PKCE でログインする。学習用 IdP であり、本番 IdP の置き換えではないことを README 先頭に書く。

## リポジトリ構成（製品モノレポ）

認証サーバー・管理 UI・サンプル RP は **デプロイ単位** として分けるが、Git は 1 本にする。一人開発で入れ子ポリレポにすると `git status` の対象が消え、クローンが空になる。

製品リポジトリはワークスペースの **兄弟** `../pf-identity`。

| パス | 役割 | デプロイ |
| --- | --- | --- |
| `apps/server` | Authorization Server。`/authorize`, `/token`, `/userinfo`, JWKS、ログイン HTML | 単一バイナリ + Postgres |
| `apps/admin` | クライアント登録、ユーザー無効化、監査ログ（未作成） | Next.js |
| `apps/sample-rp` | 接続確認用の最小 RP（未作成） | Next.js |
| `deploy/` | Compose。後に Terraform モジュール呼び出し | ローカル / 将来の IaC |

プロセスは分ける（管理 UI の依存更新で IdP バイナリを巻き込まない）。リポジトリだけを分けない。

ローカルでは `deploy/` の Compose が Postgres を上げ、`apps/server` を単体実行する。admin / sample-rp が揃ったら compose に足す。

## 技術スタック

| 層 | 採用 | 理由 |
| --- | --- | --- |
| IdP 本体 | Go | 暗号周りを薄く保ち、単一バイナリで運用しやすい |
| JWT / JWK | `lestrrat-go/jwx` 等の枯れたライブラリ。自前署名実装は禁止 |  |
| パスワード | Argon2id | bcrypt より現状の推奨に近い |
| セッション | サーバーサイドセッション + `HttpOnly` `Secure` `SameSite=Lax` Cookie | ログイン画面は IdP 起源 |
| DB | PostgreSQL | 認可コードの単回使用をトランザクションで保証 |
| 管理 UI | Next.js, TypeScript | 他プロジェクトと見た目を揃える |
| ログイン画面 | Go の html/template（サーバーレンダリング） | オープンリダイレクトと CSRF を IdP 側で完結 |
| テスト | Go test + 認可コード横取りの統合テスト。devcontainer で Postgres |  |

暗号の自前実装、implicit flow、`token` を URL フラグメントで返す実装は行わない。

## 設計思想

- **仕様の名前を使う。** 自前パラメータ `?callback=` ではなく `redirect_uri`。学習成果そのもの
- **最小の正しいフロー。** authorization code + PKCE + refresh rotation + RS256 ID Token
- **RP は信用しない。** クライアント時刻、redirect の部分一致、過剰 scope を拒否する
- **秘密はハッシュして保存。** authorization code, refresh token, client secret
- **鍵はファイルまたは KMS。** リポジトリに PEM を置かない。開発用のみ compose secret

## ドメイン

- ユーザー（email 一意、password_hash、disabled）
- クライアント（confidential / public、redirect_uris 完全一致リスト）
- 認可コード（hashed、60s、used_at）
- リフレッシュトークン（hashed、family_id、ローテーション）
- 同意（subject + client + scopes）
- 監査イベント（login_fail, consent, token_issue, revoke）

スコープ初期セット: `openid`, `profile`, `email`, `offline_access`。カスタムスコープ（`calendar.book` 等）は、利用側が必要になったフェーズで追加する。最初から細かく切ると Consent 画面が崩壊する。

## 実装順序（リポジトリ内）

1. ユーザー登録とセッションログイン（Cookie）
2. `/authorize` + Consent + code 発行
3. `/token`（authorization_code, PKCE S256）
4. ID Token と JWKS、Discovery
5. refresh ローテーション（再利用検出で family 無効化）
6. 管理 UI とクライアント CRUD
7. sample-rp を接続し、e2e を固定
8. 他プロジェクト用のクライアント登録手順（README）

## 実装上の注意点

- redirect URI はクエリ追加も含め **完全一致**。localhost のポート違いも別エントリ
- public クライアント（PWA、モバイル）は client secret を持たない。PKCE 必須
- confidential は Basic または POST で secret。secret は発行時だけ平文表示
- code は推測困難（32 bytes 以上）で、ハッシュ保存
- `/authorize` の `state` `nonce` を検証する RP 側サンプルを必ず残す
- ログイン brute-force は IP + アカウントでレート制限
- CORS は token endpoint に安易に `*` を付けない。通常の Web RP はサーバー側交換
- モバイル（P15）は authorization code をアプリが受け取る。カスタム URL スキームより **claimed HTTPS** または Expo の推奨フロー。実装時は「public + PKCE」を崩さない
- メール検証は MVP では省略可。その場合アカウント復旧を弱くする旨を README に書く
- 本番利用しない、既知の非実装（PAR, CIBA, ログアウト完全仕様）をリストする

## 他プロジェクトとの契約

発行する ID Token クレーム（最低限）:

- `iss`, `sub`, `aud`, `exp`, `iat`, `nonce`
- `email`, `email_verified`（未検証なら false）
- `name`

各 RP は `sub` を自 DB の外部キーにする。email を主キーにしない（変更されうる）。

アクセストークンは opaque でも JWT でもよい。初期は **opaque + introspect または userinfo** の方が漏洩時の被害が小さい。リソースサーバーが分散したら JWT にしてもよい。その判断は P06 以降で再訪する。

ローカル Discovery: `http://localhost:8080/.well-known/openid-configuration`

## デモ

- sample-rp でログイン → UserInfo 表示 → ログアウト
- 故意に redirect_uri を改ざんして拒否されること
- 同じ code の二回交換が失敗すること

## 非目標

- ソーシャルログインの完全仲介（後回し）
- エンタープライズ IdP（SAML）
- パスキー（WebAuthn）は推奨フェーズ。MVP を遅らせない
