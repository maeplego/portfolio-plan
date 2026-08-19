# P01 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | `pf-identity` モノレポ |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 1. 構成

```
apps/server     Go Authorization Server
apps/admin      Next.js
apps/sample-rp  Next.js RP
apps/e2e        Playwright
deploy/         Compose + Postgres
```

Store は memory と Postgres。認可コード単回はトランザクション。パスワードは Argon2id。JWT は枯れたライブラリ。自前署名実装は禁止。

## 2. データ

ユーザー（email 一意、password_hash、disabled）、クライアント（confidential / public、redirect 完全一致、logout URI）、認可コード（hashed、TTL、used_at）、リフレッシュ（hashed、family_id）、同意、監査。

鍵はファイルまたは開発用 compose secret。Git に PEM を置かない。`IDENTITY_DEV_GENERATE_KEYS` はローカル。

## 3. セッション

サーバーサイドセッション。Cookie は `HttpOnly` `SameSite=Lax`。本番相当 `Secure` は env。

## 4. 未実装

メール検証、レート制限の本格実装、パスキー。PAR / CIBA は非目標。
