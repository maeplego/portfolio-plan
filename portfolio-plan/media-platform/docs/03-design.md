# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

Git は 1 本（`apps/api` / `apps/web` / `apps/processor` + `deploy/`）。スケール特性は違うが、個人開発でリポジトリを割ると契約が複製される。

## 1. 構成

Garage（S3 互換）+ Postgres + Redis キュー。processor は Node.js + sharp。権限の正はメタデータ DB。バケットは公開しない（FR-02）。

OIDC: API は `OIDC_ISSUER`。Compose では presign ホストを `localhost:3900` に揃え path-style。

## 2. 安全な画像処理

上限の例: 20MB、4000px。マジックバイト、ピクセル爆弾対策、EXIF GPS 除去。complete 前のゴミオブジェクトはライフサイクル削除（未完成なら計画）。

## 3. 未実装

本番 S3 / SQS / Lambda イベント駆動。ローカルとイベント形を揃えるのは計画。クライアント E2E 暗号化、任意 URL fetch（SSRF）は非目標。
