# P01 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | 受け入れは現行 IdP。ソーシャルログイン等は含めない |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 1. 背景と目的

各製品がパスワードを持つとアカウントが分裂する。P01 を唯一の発行点にし、RP は OIDC 認可コード + PKCE だけを使う。学習用 IdP であり、本番 IdP の置き換えではない。

## 2. スコープ

### 含む

- ユーザー登録とセッションログイン（Cookie）
- `/authorize` + Consent + 認可コード（ハッシュ保存、単回）
- `/token`（authorization_code + PKCE S256、refresh 回転）
- ID Token（RS256）、JWKS、Discovery
- 管理 UI（クライアント CRUD、ユーザー無効化、監査）
- sample-rp と RP-Initiated / Front-Channel / Back-Channel Logout

### 含まない

| 項目 | 理由 |
| --- | --- |
| メール検証 | MVP 省略。アカウント復旧は弱い旨を README |
| ソーシャルログイン仲介 | 非目標（後回し） |
| SAML、パスキー、PAR、CIBA | 非目標 |
| アプリ固有 scope（`calendar.book` 等） | 利用側が必要になったら追加 |

## 3. アクター

| アクター | 定義 | 認証（現状） |
| --- | --- | --- |
| エンドユーザー | 登録し Consent する人 | パスワード + Cookie |
| RP | 各 `pf-*` と sample-rp | public は PKCE、confidential は secret |
| 管理者 | クライアント登録 | `IDENTITY_ADMIN_TOKEN` |

## 4. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | redirect_uri は完全一致 | オープンリダイレクト |
| FR-02 | public は secret 無し・PKCE 必須 | モバイル / PWA |
| FR-03 | code / refresh / client secret はハッシュ保存 | 漏洩時 |
| FR-04 | 同じ code の二回交換は失敗 | 認可コード横取り |
| FR-05 | refresh 再利用で family 無効化 | 盗難検出 |
| FR-06 | RP は `sub` を主キーにする。email は主キーにしない | email 変更 |
| FR-07 | token エンドポイントに CORS `*` を付けない | ブラウザ直交換を誘わない |

## 5. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | 学習用である旨を README | 本番誤用 |
| NFR-02 | リポジトリに PEM を置かない | 鍵 |

## 6. 受け入れ

1. sample-rp でログインし UserInfo が出る
2. 改ざん redirect_uri が拒否される
3. 同じ code の二回交換が失敗する（`go test` が正）
4. 一方の RP から logout するともう一方のセッションも終わる（Compose の sample-rp-b）
