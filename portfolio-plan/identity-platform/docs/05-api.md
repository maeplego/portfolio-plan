# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | `http://localhost:8080`（Compose） |

OpenAPI ファイルは未作成。Discovery は `GET /.well-known/openid-configuration`。

| メソッド | パス | 用途 |
| --- | --- | --- |
| GET | `/health` | liveness |
| GET/POST | `/register` `/login` | HTML（登録・ログイン） |
| POST | `/logout` | IdP セッション終了 |
| GET | `/authorize` | 認可 |
| POST | `/consent` | 同意 |
| POST | `/token` | authorization_code / refresh |
| GET | `/userinfo` | Bearer。opaque アクセストークン |
| GET | `/jwks.json` | 公開鍵 |
| GET/POST | `/end-session` | RP-Initiated Logout |
| GET/POST/PATCH | `/admin/api/clients` | クライアント管理。管理者トークン必須 |
| GET | `/admin/api/users` | ユーザー一覧 |
| POST | `/admin/api/users/{id}/disabled` | 無効化 |
| GET | `/admin/api/audits` | 監査 |

ID Token クレームは要件 FR-06 と [02-specification.md](02-specification.md)。secret の平文は作成・rotate 応答に一度だけ。
