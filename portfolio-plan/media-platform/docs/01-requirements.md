# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

Wiki・商品・ブログ・チャットがそれぞれオブジェクトストレージのクライアントを持つと、権限と派生画像の規則がすぐずれる。メディア基盤は **オブジェクト本体と画像派生** を共有する。学習用であり、商用 CDN の置き換えではない。

## 2. 含む

- presign PUT、complete、クォータ、フォルダ、期限付き共有リンク（パスワード任意）
- 画像ジョブ（`orig` の EXIF GPS 除去、`detail` 最大辺 1920 WebP、`thumb` 320）
- マイドライブ UI
- 開発認証、または認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) の OIDC
- 単体 Compose（Garage + API + processor + Web）

呼び出し側の例: ワークスペース [pf-workspace](https://github.com/maeplego/pf-workspace)、EC [pf-commerce](https://github.com/maeplego/pf-commerce)、ブログ [pf-content-blog](https://github.com/maeplego/pf-content-blog)。未接続時は各製品がローカル保存や URL 文字列で動く。

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| クライアント側 E2E 暗号化 | 範囲外 |
| 動画トランスコード | 範囲外 |
| 任意 URL の fetch | SSRF |
| ウイルススキャン | 種別制限で代替 |
| 本番の S3 → SQS → Lambda | ローカルは Redis キュー + 常駐 processor |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| 所有者 | `sub` に紐づくドライブの利用者 | 開発ヘッダまたは OIDC |
| 共有リンクのゲスト | トークンで 1 ファイルを取る人 | 共有トークン（パスワード任意） |
| processor | 派生を書いて finish する | 内部トークン |

## 5. 前提

- 実体は Garage（S3 互換）。バケットは非公開
- key は `user/{sub}/ulid`
- `purpose` は `drive` / `wiki` / `chat` / `blog` / `blog-cover` / `product`（空は `drive`）
- クォータは org キー（サービス層）。上限の例: 20MB、4000px。巨大画像は 413
- 内部プレフィックス `service/{service}/` は将来

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 実体はアプリメモリを通さない（presign PUT / 署名付き GET） | 巨大アップロード |
| FR-02 | 権限の正はメタデータ DB。バケット非公開 | 推測 GET |
| FR-03 | 画像処理は非同期。同期リサイズでタイムアウトさせない | 待ち時間 |
| FR-04 | object key は `user/{sub}/ulid` | path traversal と他ユーザー prefix の推測 |
| FR-05 | クォータ超過は complete を拒否し、ゴミオブジェクトを残さない方針 | 課金相当の学習 |
| FR-06 | 公開共有の応答に他人のファイル名一覧を出さない | PII |
| FR-07 | 他人のファイル GET は 404（存在を 403 で漏らさない） | 列挙 |
| FR-08 | 共有リンクは高エントロピートークン。期限切れは 4xx。一覧・削除は所有者のみ | 推測と放置リンク |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | マジックバイトとピクセル爆弾対策がある | 安全な画像処理 |
| NFR-02 | README に学習用であることと上限を書く | 誤用 |
| NFR-03 | 単体 Compose でドライブ UI まで起動できる | 単独デモ |

## 8. 受け入れ

1. ブラウザから画像を投げ、数秒後にサムネイルが出る
2. 巨大画像が 413
3. 共有リンクでダウンロードでき、期限切れは 4xx。パスワード付きも動作する
4. 公開応答に他ユーザーのファイル名一覧が無い
