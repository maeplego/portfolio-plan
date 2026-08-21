# 顧客バケット手順（Blob / S3 互換）

| 項目 | 値 |
| --- | --- |
| 対象 | Collab 添付（P03 `pf-media`）を顧客管理のオブジェクトストアに向ける |
| 最終更新 | 2026-08-21 |

開発既定は Compose 内 Garage。商用では **顧客バケット（または顧客アカウント上のバケット）** に差し替え可能。CDN・ウイルススキャン・動画変換は対象外。

## 環境変数（API / processor）

| 変数 | 意味 | 顧客バケット例 |
| --- | --- | --- |
| `MEDIA_S3_ENDPOINT` | S3 API ホスト（スキームなし可） | `s3.ap-northeast-1.amazonaws.com` または R2 エンドポイント |
| `MEDIA_S3_PUBLIC_ENDPOINT` | 署名 URL に載せるホスト（ブラウザから到達可能） | CloudFront / 公開エンドポイント。空なら endpoint を流用 |
| `MEDIA_S3_REGION` | リージョン文字列 | `ap-northeast-1` / `auto`（R2） |
| `MEDIA_S3_ACCESS_KEY` / `MEDIA_S3_SECRET_KEY` | 認証 | IAM ユーザまたは R2 API トークン。Git に置かない |
| `MEDIA_S3_BUCKET` | バケット名 | 顧客専用バケット |
| `MEDIA_S3_USE_SSL` | TLS | 本番は `true` |

互換エイリアス: `MEDIA_MINIO_*`（旧名）。実装は `pf-media/apps/api/internal/config`。

## 手順（概要）

1. 顧客側でバケットを作成し、**公開 ACL は付けない**（presign のみで PUT/GET）。
2. 最小権限のアクセスキーを発行（オブジェクト CRUD + `ListBucket` 程度。アカウント横断は不要）。
3. staging / 本番の Secret に上記変数を入れる。Compose なら `deploy/.env`（コミットしない）。
4. API 起動時に `EnsureBucket` が走る。既存バケットなら存在確認のみ。
5. 疎通: `presign` → PUT 1 バイト → `complete` → 派生ジョブ（画像）が動くこと。

## 境界と注意

- メタデータ（所有者・クォータ・共有リンク）は **Postgres**。オブジェクト本体だけ差し替え。
- エンドポイントを替えると **旧バケット上のオブジェクトは見えない**。移行はコピーまたはダウンタイム付き切替を別途計画する。
- 顧客バケットに切り替えたあとも `MEDIA_DEV_AUTH=true` は staging 以上で禁止（Collab ゲートと同じ）。

## 関連

- [production-definition.md](../../production-definition.md)（オブジェクト格納ゲート）
- [03-design.md](03-design.md)
- `pf-media/deploy/.env.example`
