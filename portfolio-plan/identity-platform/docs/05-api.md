# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | `http://localhost:8080`（Compose） |

OpenAPI ファイルは未作成。Discovery は `GET /.well-known/openid-configuration`（`scopes_supported` に `org` を含む）。

| メソッド | パス | 用途 |
| --- | --- | --- |
| GET | `/health` | liveness |
| GET/POST | `/register` `/login` | HTML（登録・ログイン） |
| POST | `/logout` | IdP セッション終了 |
| GET | `/authorize` | 認可 |
| POST | `/consent` | 同意 |
| POST | `/token` | authorization_code / refresh |
| GET | `/userinfo` | Bearer。opaque アクセストークン。`org` スコープ時は `org_id` 等 |
| GET | `/jwks.json` | 公開鍵 |
| GET/POST | `/end-session` | RP-Initiated Logout |
| POST | `/v1/organizations` | Bearer。組織作成（作成者は owner） |
| GET | `/v1/organizations` | Bearer。所属組織一覧 |
| GET | `/v1/organizations/{id}/members` | Bearer。メンバー一覧（所属者のみ） |
| PUT | `/v1/active-org` | Bearer（アクセストークンに session SID 必須）。アクティブ組織切替 |
| PUT | `/account/active-org` | セッション Cookie。HTML アカウント画面向け |
| GET/POST/PATCH | `/admin/api/clients` | クライアント管理。管理者トークン必須 |
| GET/POST | `/admin/api/organizations` | 組織一覧・作成（owner_email または owner_user_id） |
| GET | `/admin/api/organizations/{id}` | 組織詳細 |
| GET/POST | `/admin/api/organizations/{id}/members` | メンバー一覧・追加（email または user_id、role） |
| PATCH/DELETE | `/admin/api/organizations/{id}/members/{userId}` | role 変更・除名（唯一 owner は 403） |
| GET | `/admin/api/users` | ユーザー一覧 |
| POST | `/admin/api/users/{id}/disabled` | 無効化 |
| GET | `/admin/api/audits` | 監査 |

Compose は `IDENTITY_SEED_EXTRA_CLIENTS` で複数 RP を seed する。Kubernetes overlay の seed は最小セット（issuer／redirect がクラスタ DNS）のため、ローカル Compose とクライアント ID 一覧は一致しないことがある。差分は各 overlay の ConfigMap／env を正とする。

ID Token クレームは要件 FR-06 と [02-specification.md](02-specification.md)。secret の平文は作成・rotate 応答に一度だけ。
