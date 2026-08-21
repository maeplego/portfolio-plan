# 運用 Runbook（Collab）

| 項目 | 値 |
| --- | --- |
| 対象 | P04 Workspace ± P01 / P03 |
| 最終更新 | 2026-08-21 |

## 障害対応（初動）

| 症状 | 確認 | 対処 |
| --- | --- | --- |
| ログインできない | IdP `/health`、issuer、JWKS、時刻ずれ | IdP 再起動。staging では DEV_GENERATE_KEYS 禁止を確認 |
| API 401 | `WORKSPACE_DEV_AUTH` が staging で誤って true になっていないか、Bearer / org | トークン再取得。`org_id` 必須 |
| データが消えたように見える | org 切替後の別テナント | OrgSwitcher と `org_id` を確認 |
| Wiki/Docs 同期不可 | collab `/health`、INTERNAL_TOKEN | collab 再起動。api とトークン一致 |
| チャット不通 | api `/chat/ws`、Ingress | api 再起動。WS パスのプロキシ設定 |

## デプロイ／ロールバック

1. イメージ tag を記録してから apply
2. `kubectl rollout status` で api / collab / web
3. 失敗時は前 tag に戻し `rollout undo`

## バックアップ／リストア

- Postgres（workspace / idp）の論理バックアップを staging で月次相当に実演
- リストア後: migrate／seed クライアント確認、ログイン 1 回

## 関連

- [production-definition.md](../../production-definition.md)
- [collab-staging.md](../../collab-staging.md)
- [08-commercial-intro.md](08-commercial-intro.md)
