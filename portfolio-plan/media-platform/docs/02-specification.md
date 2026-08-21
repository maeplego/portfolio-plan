# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

所有者・共有リンクのゲスト・processor から見た振る舞い。内部のキューは [03-design.md](03-design.md)。

## 1. 認証

単体デモは `?user=` と `X-Dev-User-Sub`。OIDC 時は JWT または opaque + userinfo で `sub`。発行点は認証基盤 [pf-identity](https://github.com/maeplego/pf-identity)。

`/v1/*` はユーザー認証必須。共有 GET はトークン（パスワード任意は `X-Share-Password`）。内部 finish は processor トークン。

## 2. アップロード

1. クライアントが `POST /v1/uploads/presign`（`contentType`, `size`, `purpose`）
2. 返った URL へ Garage（S3 互換）に PUT。バイトは API メモリを通さない（FR-01）
3. `POST /v1/uploads/complete`（`fileId`, `etag`）。etag 不一致・空（オブジェクトに etag がある場合）は拒否。クォータ超過は拒否（FR-05）
4. 画像なら job が `queued`。processor が派生を書き `finish`
5. 非画像はストレージのみ。job を切らない

purpose ホワイトリスト: `drive`, `wiki`, `chat`, `blog`, `blog-cover`, `product`（空は `drive`）。呼び出し側の例: チーム作業場所 [pf-workspace](https://github.com/maeplego/pf-workspace)、EC [pf-commerce](https://github.com/maeplego/pf-commerce)、ブログ [pf-content-blog](https://github.com/maeplego/pf-content-blog)。内部プレフィックス `service/{service}/` は将来。

オブジェクト key は `user/{sub}/ulid`（FR-04）。他人のファイル GET / complete / 削除は 404（存在を漏らさない）。クォータは org キー（サービス層）。

## 3. 画像派生

非同期（FR-03）。`orig` は EXIF GPS 除去、`detail` 最大辺 1920 WebP、`thumb` 320。上限の例: 20MB、4000px。マジックバイトとピクセル爆弾対策。巨大画像は 413。

本番の S3 → SQS → Lambda は未実装。ローカルは Redis キュー + 常駐 processor。

## 4. 共有とドライブ UI

共有リンクは高エントロピートークン。作成時にパスワードを任意設定できる。`GET /v1/s/{token}` はメタ、download は署名付き。期限切れは 4xx。公開応答に他人のファイル名一覧を出さない（FR-06）。所有者は `GET /v1/share-links` と `DELETE /v1/share-links/{token}` で一覧・削除できる。

マイドライブ UI は実装済み（フォルダ、一覧、サムネ）。ウイルススキャンと動画トランスコードは非目標。
