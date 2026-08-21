# Collab 商用導入（評価 → 商用）

| 項目 | 値 |
| --- | --- |
| 最終更新 | 2026-08-21 |

## プロファイル

| プロファイル | 認証 | 用途 |
| --- | --- | --- |
| 同梱 IdP | P01 + OIDC | 既定。評価〜小規模本番 |
| BYO IdP | 顧客 OIDC（または `deploy/byo-oidc` モック） | ロックイン回避。`active-org` なし可 |

## 切替チェックリスト

1. [production-definition.md](../../09-production-definition.md) の Collab ゲートを記入
2. staging: `WORKSPACE_ENV=staging`、`WORKSPACE_DEV_AUTH=false`（overlay: `docker-desktop-b-collab-staging`）
3. 同梱: デモユーザ／クライアント seed。BYO: [portability-byo-idp.md](../../13-portability-byo-idp.md) と `pf-workspace/deploy/byo-oidc/README.md`
4. E2E: `pf-workspace/apps/e2e`（同梱経路）
5. 運用: [07-operations-runbook.md](07-operations-runbook.md)
6. ライセンス: 評価 LICENSE → 商用契約（[licensing.md](../../15-licensing.md)）

給与・税務は対象外（P16（給与・税務））。
