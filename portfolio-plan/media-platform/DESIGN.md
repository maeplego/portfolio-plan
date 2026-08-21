# P03 media-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/13-file-storage-sharing.md`
- `portfolio-idea/28-serverless-image-pipeline.md`

アップロードを組み込む側（P04, P06, P08）の `DESIGN.md` も、結合時は渡す。

## 対応アイデア

- 13 ファイル共有ストレージ
- 28 サーバーレス画像処理パイプライン

## 目的

オブジェクト本体の保存と、画像の派生生成を **1 つのメディア基盤** にする。Wiki 添付、商品画像、ブログ画像、チャット画像がそれぞれ S3 クライアントを再実装しない。

13 はメタデータ・権限・共有リンク、28 は非同期の画像変換。同じバケット規約とジョブ状態機械を使う。

## リポジトリ構成（ポリレポ）

アップロード API と画像ワーカーはスケール特性が違う（API は待ち時間、ワーカーは CPU / Lambda 制限）。ポリレポ。

| リポジトリ | 役割 |
| --- | --- |
| `pf-media-api` | メタデータ、presign、共有リンク、クォータ、ジョブ状態 API |
| `pf-media-web` | マイドライブ UI（アイデア 13 の画面デモ） |
| `pf-media-processor` | 画像派生（sharp）。ローカルは常駐ワーカー、本番は Lambda または同等 |
| `pf-media-infra` | Garage + Compose。AWS なら S3, SQS, Lambda, CloudFront のモジュール（P02 を利用） |

`pf-media-web` は製品デモ用。P04 などは API だけを呼ぶ。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| API | Go, PostgreSQL |
| Web | Next.js |
| 処理 | Node.js + sharp、または Go + 制約のあるリサイズ。Lambda に載せるなら sharp レイヤーが現実的 |
| オブジェクト | Garage（開発、S3 互換）、S3 / R2（本番） |
| キュー | 開発 Redis または Garage 通知 + ワーカー。本番 SQS + DLQ |
| 認証 | P01 OIDC。サービス間は後で M2M（client credentials）を検討 |

## 設計思想

- **実体はアプリメモリを通さない。** presign PUT / 署名付き GET
- **メタデータ DB が権限の正。** バケットを公開しない
- **画像処理は非同期。** 同期リサイズ API でタイムアウトさせない
- **冪等。** 同じ object key の再処理は派生を上書き
- **安全な画像処理。** ピクセル数上限、マジックバイト、EXIF GPS 除去

## 統合の形

アップロード完了（`complete`）後:

1. MIME が画像ならジョブ `queued` を切る
2. processor が原画を読み、バリエーションを書く（`orig` は EXIF 除去済み、`detail` 最大辺 1920 WebP、`thumb` 320）
3. API が `assets` を更新。呼び出し側は `thumb` URL を一覧に使う

非画像（PDF、ソース zip 等）は 13 のストレージ機能だけ。公開デモでは MIME ホワイトリストを狭くする。

## 実装順序

1. ローカルディスク版の CRUD で権限モデルを固める（すぐ捨ててよい）
2. Garage + presign + complete + クォータ
3. 共有リンク（期限、パスワード任意）
4. キュー + processor（同期関数として単体テストしてから非同期化）
5. DLQ、再実行 API、ピクセル爆弾対策
6. `pf-media-web` のドライブ UI
7. 本番イベント駆動（S3 → SQS → Lambda）は P02 のあと。ローカルとイベント形を揃える

## 実装上の注意点

- `complete` 前のゴミオブジェクトはライフサイクルで削除
- path traversal、他ユーザー prefix の推測。key は `user/{sub}/ulid`
- クォータ超過は complete で拒否し、オブジェクトを消す
- 共有トークンは高エントロピー。一覧で他人のファイル名を出さない
- Lambda のメモリ/時間に乗らない画像は「拒否」か「ECS に振る」。README に上限（例: 20MB、4000px）
- ウイルススキャンは発展。デモは種別制限で代替
- 公開 SaaS として任意 URL を fetch する実装は SSRF になるので禁止（プロセッサは自バケットのみ）

## 組織テナント（IdP org）

- OIDC 時は `org` scope 必須。`org_id` が無いトークンは API が拒否する
- ファイル／フォルダ／共有リンクに `org_id` をスタンプし、一覧・操作は `owner_sub` + `org_id` で拘束
- Web は OrgSwitcher（IdP `PUT /v1/active-org` + refresh）。dev-auth は `X-Dev-User-Org`（省略時 `org-demo-a`）
- `purpose` はアップロード種別のまま（テナントキーにしない）

## 他プロジェクトとの契約

同期 API（概要）:

- `POST /v1/uploads/presign` `{ contentType, size, purpose }`
- `POST /v1/uploads/complete` `{ key, etag }`
- `GET /v1/files/:id` メタデータと派生 URL
- `POST /v1/share-links`

`purpose`: `wiki`, `product`, `blog`, `chat`, `drive`。クォータと公開可否のポリシーに使う。

内部利用（P06 カタログ等）はユーザーの drive ではなく `service/{service}/...` プレフィックス。認可は M2M またはユーザーの委任。

## デモ

- ブラウザから画像を投げ、数秒後にサムネイルが出る
- 2 ユーザーで共有リンクの期限切れ
- 巨大画像が 413 になる

## 非目標

- クライアント側 E2E 暗号化
- 動画トランスコード
- 汎用 CDN 設定のやり込み（最低限でよい）
