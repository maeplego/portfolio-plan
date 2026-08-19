# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

要件の「何を守るか」に対し、プロセスと永続化で「どう守るか」。スタックの短文は親の `DESIGN.md`。

## 1. 構成

Git は 1 本の製品リポジトリ。デプロイ単位だけ分ける。

```
apps/server     Go Authorization Server
apps/admin      Next.js 管理 UI
apps/sample-rp  Next.js の最小 RP
apps/e2e        Playwright
deploy/         Compose + Postgres
```

Store は memory と Postgres。認可コードの単回使用はトランザクション。パスワードは Argon2id。JWT は枯れたライブラリ（例: `lestrrat-go/jwx`）。自前の署名実装は置かない。

## 2. データ

- ユーザー: email 一意、`password_hash`、`disabled`
- クライアント: confidential / public、`redirect_uri` 完全一致、logout URI
- 認可コード: ハッシュ保存、短い TTL、`used_at`
- リフレッシュ: ハッシュ、`family_id`、回転
- 同意（subject + client + scopes）
- 監査（login_fail, consent, token_issue, revoke など）

署名鍵はファイルまたは開発用 Compose の secret。Git に PEM を置かない。`IDENTITY_DEV_GENERATE_KEYS` はローカル専用。

## 3. セッション

サーバーサイドセッション。Cookie は `HttpOnly` `SameSite=Lax`。`Secure` は環境変数で本番相当にする。ログイン HTML は IdP 起源のサーバーレンダリング。

## 4. セキュリティの守り方

- RP の時刻や部分一致 redirect を信じない
- code / refresh / client secret はハッシュして保存（FR-03）
- public クライアントは secret 無し・PKCE 必須（FR-02）
- implicit flow や URL フラグメントで token を返す実装はしない

## 5. 未実装・非目標

未実装: メール検証、本格的なレート制限。

非目標: パスキー、ソーシャルログイン仲介、SAML、PAR、CIBA。
