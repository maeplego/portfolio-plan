# 監査イベント（本番必須一覧）

| 項目 | 値 |
| --- | --- |
| 最終更新 | 2026-08-21 |

`audit_events` に残る型（コード定数）。秘密（パスワード・トークン生値）は note に書かない。

| type | いつ | 本番必須 |
| --- | --- | --- |
| `login_fail` | パスワード不一致など | Yes |
| `consent` | 認可同意 | Yes |
| `token_issue` | トークン発行 | Yes |
| `revoke` | refresh 失効／ファミリー失効 | Yes |

未実装だが本番ゲートで「あるとよい」もの（足りなければ Risk Accept または後続スライス）:

- ログイン成功（現状は fail のみ）
- org 切替（`/v1/active-org` 相当）
- 管理者によるクライアント／ユーザ変更

## 保持期間方針（初期）

| 環境 | 目安 |
| --- | --- |
| demo | 永続不要（DB 再作成可） |
| staging | 30 日以上 |
| production | 90 日以上（契約で延長可）。削除はバッチ未実装のため運用でエクスポート後に DB メンテ |

一覧 API: admin の audits（`IDENTITY_ADMIN_TOKEN` 必須）。
