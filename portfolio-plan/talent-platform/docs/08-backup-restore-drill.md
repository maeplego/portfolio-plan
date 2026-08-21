# Talent path バックアップ／リストア実演記録

| 項目 | 値 |
| --- | --- |
| 対象 | P10 `talent` + P05 `calendar`（platform Postgres） |
| 最終更新 | 2026-08-21 |

Collab の正本手順は [workspace/docs/09-backup-restore-drill.md](../workspace/docs/09-backup-restore-drill.md)。本書は Talent path 実演の記録。

## 記録欄

| 項目 | 記入 |
| --- | --- |
| 日付（UTC） | 2026-08-21 |
| 環境 | `docker-desktop-c-scheduling-talent-staging` |
| 担当 | portfolio agent |
| 対象 DB | talent / calendar |
| バックアップ手段 | `pg_dump -Fc`（platform Postgres Pod 内） |
| バックアップ成果物の保管場所 | Pod `/tmp/*.dump`（ホスト TEMP への `kubectl cp` は任意。Git に置かない） |
| リストア先 | `talent_drill` / `calendar_drill` |
| 所要時間 | 約 5 分 |
| 結果 | **Pass** |
| 残課題 | recommend DB は任意。顧客環境はマネージドスナップショットに合わせる |

## 確認内容

1. public テーブル数一致（talent 5 / calendar 7）
2. `pg_restore` 成功（exit 0）
3. Talent API を短時間 drill DB に向けたうえで `/health` を確認し、staging overlay 再 apply で primary に復帰

## 関連

- [talent-staging.md](../../21-talent-staging.md)
- [07-talent-gate.md](07-talent-gate.md)
