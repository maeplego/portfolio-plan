# P03 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P03 media-platform |
| 対象スライス | `pf-media` モノレポ（api / web / processor） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

Garage（S3 互換）+ Postgres + Redis キュー。processor は sharp。上限の例: 20MB、4000px。マジックバイト、ピクセル爆弾対策。complete 前のゴミはライフサイクル（未完成なら計画）。

OIDC: API は `OIDC_ISSUER`。Compose では presign ホストを `localhost:3900` に揃え path-style。

本番 S3/SQS/Lambda は未実装。ローカルとイベント形を揃えるのは計画。
