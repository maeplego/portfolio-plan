# P01 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | 現行 HTTP。OpenAPI は未作成 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | `http://localhost:8080` |

Discovery: `GET /.well-known/openid-configuration`

| メソッド | パス | 用途 |
| --- | --- | --- |
| GET | `/health` | liveness |
| GET/POST | `/register` `/login` | HTML |
| POST | `/logout` | IdP セッション |
| GET | `/authorize` | 認可 |
| POST | `/consent` | 同意 |
| POST | `/token` | code / refresh |
| GET | `/userinfo` | Bearer |
| GET | `/jwks.json` | 公開鍵 |
| GET/POST | `/end-session` | RP-Initiated Logout |
| GET/POST/PATCH | `/admin/api/clients` | 管理。トークン必須 |
| GET | `/admin/api/users` | 一覧 |
| POST | `/admin/api/users/{id}/disabled` | 無効化 |
| GET | `/admin/api/audits` | 監査 |

ID Token クレームは要件 FR-06 と DESIGN。secret の平文は作成・rotate 応答に一度だけ。
