# Commerce バックアップ／リストア実演記録

| 項目 | 値 |
| --- | --- |
| 対象 | P06（`commerce_gateway` / `commerce_order`。他 commerce_* は同手順） |
| 最終更新 | 2026-08-21 |

Collab の正本手順は [workspace/docs/09-backup-restore-drill.md](../workspace/docs/09-backup-restore-drill.md)。本書は Commerce 実演の記録。

## 記録欄

| 項目 | 記入 |
| --- | --- |
| 日付（UTC） | 2026-08-21 |
| 環境 | `docker-desktop-d-commerce-staging` |
| 担当 | portfolio agent |
| 対象 DB | commerce_gateway / commerce_order |
| バックアップ手段 | `pg_dump -Fc` |
| バックアップ成果物の保管場所 | ホスト TEMP `pf-commerce-backup-drill-20260821/`（Git に置かない） |
| リストア先 | `commerce_gateway_drill` / `commerce_order_drill` |
| 所要時間 | 約 5 分 |
| 結果 | **Pass** |
| 残課題 | catalog/inventory 等も同型で可。PCI 決済 DB は対象外（モック） |

## 確認内容

1. public テーブル数一致（gateway 1 / order 4）
2. gateway を短時間 `commerce_gateway_drill` に向け `/health` `/ready` 後、primary に復帰

## 関連

- [commerce-staging.md](../../20-commerce-staging.md)
- [07-commerce-gate.md](07-commerce-gate.md)
