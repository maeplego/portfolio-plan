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
| 招待メールが届かない | メール送信設定・ログ、招待トークン期限 | 再送 API。SMTP 未設定なら「リンク手渡し」運用を顧客に明示 |
| 添付が 403 / 署名失敗 | media `/health`、`MEDIA_S3_*`、時刻 | media 再起動。顧客バケット手順を確認 |

## 共同編集（collab）

1. 症状: カーソルが動かない／差分が戻る → collab と api の `INTERNAL_TOKEN`、部屋 ID（`collabDocumentId`）を確認。
2. sticky Session が必要な Ingress では同一 Pod に寄せる。ロールアウト中は編集中セッションが切れることを顧客に伝える。
3. guest は read-only。書き込みできないのは正常。

## チャット

1. HTTP 履歴は api。リアルタイムは `/chat/ws?ticket=&channelId=`（Yjs と別ソケット）。
2. 投稿 403: guest ロールか、チャンネル所属外。
3. 未読バッジずれ: api 再起動後も残るならクライアント再読込。永続削除はしない（監査）。

## 招待・公開範囲（要約）

| 経路 | 見える範囲 | 備考 |
| --- | --- | --- |
| workspace メンバー（owner/member/guest） | ロール表どおり（仕様 02） | guest は draft Wiki 非表示・投稿不可 |
| 招待リンク | トークン保持者のみ accept | 期限・revoke・resend あり。メール照合 |
| 共有メディアリンク | media 側トークン | バケット自体は非公開 |
| 未所属 | 一覧・詳細とも不可 | 403 / 非表示 |

詳細の正は [02-specification.md](02-specification.md) と招待関連テスト。顧客向け一枚絵は M2 で継続。

## デプロイ／ロールバック

1. イメージ tag を記録してから apply
2. `kubectl rollout status` で api / collab / web
3. 失敗時は前 tag に戻し `rollout undo`

## バックアップ／リストア

- 手順と実演記録テンプレ: [09-backup-restore-drill.md](09-backup-restore-drill.md)
- Postgres（workspace / idp）の論理バックアップを staging で一度実演し、テンプレを記入する（本番 Go のブロッカー）
- リストア後: migrate／seed クライアント確認、ログイン 1 回、org 切替 1 回

## 関連

- [production-definition.md](../../09-production-definition.md)
- [collab-staging.md](../../19-collab-staging.md)
- [08-commercial-intro.md](08-commercial-intro.md)
- [media-platform/docs/07-customer-bucket.md](../../media-platform/docs/07-customer-bucket.md)
