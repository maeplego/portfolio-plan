# OAuth 2.0 / OIDC 認証基盤

自前 IdP（Identity Provider）を小さな範囲で実装し、認可コードフロー、PKCE、JWT、Consent 画面まで作ります。セキュリティエンジニアやバックエンド志望で差が付きます。本番 IdP の置き換えではなく、学習用実装であることを明記します。

## 概要

ユーザー登録、ログイン、クライアント（RP）登録、認可コード発行、トークン発行、UserInfo、簡単な SSO（複数 RP）を提供します。Authorization Server と簡易リソースサーバーをセットにします。

## 就職活動でのアピールポイント

- OAuth 2.1 / OIDC の用語を正確に使える
- PKCE、redirect URI 厳密一致、state/nonce
- パスワードのハッシュ（Argon2id）、セッション
- JWT の署名（RS256）、鍵ローテーションの話
- よくある脆弱性（redirect の緩い一致、過剰な scope）を避ける実装

## 解決する課題

複数アプリでログインを繰り返したくない。学習として「Auth0 の中身」を理解する。

## 想定ユーザー

自作アプリ 2 つ（ブログ管理画面と家計簿）をこの IdP に接続する、という物語が面接向きです。

## 主要機能

### 必須（MVP）

- ユーザー登録、ログイン、ログアウト
- クライアント登録（confidential / public）
- 認可コードフロー + PKCE
- トークンエンドポイント（authorization_code, refresh_token）
- ID Token（OIDC）、UserInfo
- Consent 画面（openid, profile, email）

### 推奨

- Discovery（`.well-known/openid-configuration`）、JWKS
- ログアウト（RP-initiated の簡易版）
- 管理画面でクライアントの redirect URI 編集
- 監査ログ（ログイン失敗、トークン発行）
- MFA TOTP（任意だが強い）

### 発展

- Device flow、Client credentials（M2M）
- Passkeys（WebAuthn）
- ソーシャルログイン（GitHub）を IdP が仲介

## 画面構成

| 画面 | 役割 |
| --- | --- |
| ログイン | IdP 共通 |
| Consent | アプリが求める権限 |
| アカウント | 接続済みアプリの取り消し |
| 管理 | クライアント CRUD |

## API 概要（標準に寄せる）

- `GET /authorize`
- `POST /token`
- `GET /userinfo`
- `GET /jwks.json`
- `POST /revoke`（推奨）

自作パラメータ名にせず、仕様の名前を使うことが学習成果です。

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| 実装言語 | Go / TypeScript（oidc-provider を「使う」のではなく、核を自前実装） |
| DB | PostgreSQL |
| 暗号 | ライブラリ必須（自前暗号禁止）。jose、golang-jwt 等 |
| フロント | ログイン画面はサーバレンダリングが安全で説明しやすい |
| 検証 | 公式の仕様テストは重いので、自前の認可コード横取りテストを書く |
| インフラ | Docker、GitHub Actions |

ライブラリを全面的に使うとアピールが薄いので、「トークン発行と PKCE 検証は自前、暗号演算は枯れたライブラリ」と線を引きます。

## アーキテクチャ

RP → `/authorize` → ログイン済みでなければログイン → Consent → `code` を redirect → RP が `/token` で code+verifier 交換 → access token + id token。code は単回使用、短命。refresh はローテーション。

## データモデル（概要）

- `users`（password_hash）
- `clients`（client_id, secret_hash, redirect_uris, token_endpoint_auth_method）
- `authorization_codes`（hashed, expires, used）
- `refresh_tokens`（hashed, family_id）
- `consent_grants`

## セキュリティ・品質

- シークレットとコードはハッシュ保存
- redirect URI は完全一致（クエリの追加も拒否）
- open redirect 禁止
- ログイン brute-force 対策
- 本番利用しない旨を README の先頭に書く

## 実装の進め方

1. セッションログイン
2. 認可コード + PKCE + token
3. ID Token と JWKS
4. refresh ローテーション
5. サンプル RP を 1 つ添付

## 工数目安

- MVP: 3 週間（仕様読解含む）
- 推奨: 5 週間

## 面接での話し方

「implicit を実装しなかった理由（非推奨）」「access token を JWT にした/しない判断」を話せると十分です。完璧な認定 IdP を名乗らないこと。

## 公開時のチェックリスト

- シーケンス図
- 意図的に入れなかったフローのリスト
- サンプル RP の起動手順
