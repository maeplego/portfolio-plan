# BYO IdP 接続手順（Collab／AuthPort）

| 項目 | 値 |
| --- | --- |
| 最終更新 | 2026-08-21 |
| 契約の正本 | [portability.md](../portability.md) |

同梱 P01 の代わりに、顧客またはラボの OIDC IdP（Entra、Auth0、Keycloak 等）を使う手順の骨子。

## 前提

- Authorization Code + PKCE
- 公開クライアント（workspace web）または機密クライアントの方針を決める
- アクセストークン／ID トークンに `sub`
- テナント: クレーム `org_id`、またはカスタムクレームを RP 側でマッピング（実装は Phase 1–2 で寄せる）

## チェックリスト

1. IdP にアプリ登録: redirect `…/callback`、logout redirect
2. issuer・JWKS・client_id を staging の `OIDC_*` に設定
3. `WORKSPACE_ENV=staging`、`WORKSPACE_DEV_AUTH=false`
4. 同梱 P01 を止めるか、issuer を顧客 IdP のみにする（混在しない）
5. ログイン → workspace ホーム →（可能な範囲で）org 表示を確認
6. 境界: 別 org のデータが見えないこと

## P01 固有 API への依存（棚卸しメモ）

Workspace は org メンバー一覧や active-org 切替で **同梱 IdP の `/v1/...` を呼ぶ経路がある**。BYO 時は:

- メンバーディレクトリが IdP に無い場合は「切替 UI を制限」または「クレームのみで単一 org」に落とす
- 汎用化は Phase 1–2 の改修対象（ハードコード増加禁止）

詳細なエンドポイント表は実装追随後に本ファイルへ追記する。
