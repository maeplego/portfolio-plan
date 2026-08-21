# 脅威モデル（1 枚）

| 項目 | 値 |
| --- | --- |
| 対象 | P01 Identity（学習 IdP → Collab 同梱アダプタ） |
| 最終更新 | 2026-08-21 |

## 資産

- ユーザ認証情報（パスワードハッシュ）
- セッション Cookie、認可コード、refresh トークン
- RSA 署名鍵、admin トークン
- org メンバーシップと active org

## 主な脅威と緩和

| 脅威 | 緩和（現状／方針） |
| --- | --- |
| デモ用一時鍵の本番利用 | `IDENTITY_ENV=staging|production` で `DEV_GENERATE_KEYS` 拒否 |
| memory store の消失・共有不可 | staging/production は postgres 必須 |
| Cookie 盗聴 | production は `COOKIE_SECURE=true` |
| 認可コード再利用 | 一回限り消費（既存テスト） |
| refresh 盗難 | ローテ／ファミリー revoke（既存） |
| admin API 露出 | bearer 必須。弱い固定トークンを Git に置かない |
| BYO IdP 誤設定 | [portability.md](../../portability.md) のクレーム契約と staging 手順 |
| フィッシング／XSS でセッション奪取 | HttpOnly Cookie、RP 側の通常 Web 対策（アプリ側） |

## 範囲外（この IdP では扱わない）

- パスキー、SAML、メール検証必須化
- 給与・税務データ（第 N 弾／外部）
- ペネトレーションテスト正式レポート（Enterprise 別）

学習用であることの注意は製品 `SECURITY.md` も参照。商用契約時は本番定義ゲートを満たすこと。
