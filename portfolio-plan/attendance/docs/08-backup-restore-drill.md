# Attendance バックアップ／リストア実演記録

| 項目 | 値 |
| --- | --- |
| 対象 | P09 `attendance`（platform Postgres） |
| 最終更新 | 2026-08-21 |

Collab の正本手順は [workspace/docs/09-backup-restore-drill.md](../workspace/docs/09-backup-restore-drill.md)。本書は Attendance 実演の記録。

## 記録欄

| 項目 | 記入 |
| --- | --- |
| 日付（UTC） | 2026-08-21 |
| 環境 | `docker-desktop-f-ops-staging` |
| 担当 | portfolio agent |
| 対象 DB | attendance |
| バックアップ手段 | `pg_dump -Fc`（platform Postgres Pod 内） |
| バックアップ成果物の保管場所 | Pod `/tmp/attendance.dump`（Git に置かない） |
| リストア先 | `attendance_drill` |
| 所要時間 | 約 5–10 分 |
| 結果 | **Pass** |
| 残課題 | 顧客環境はマネージドスナップショット手順に合わせる。労基監査証跡は対象外（名乗らない） |

## 確認内容

1. public テーブル数一致（attendance **6**）
2. `pg_restore` 成功（exit 0）
3. API を短時間 `attendance_drill` に向け `/health` `/ready` を確認後、staging overlay 再 apply で primary に復帰

## 関連

- [attendance-staging.md](../../attendance-staging.md)
- [07-attendance-gate.md](07-attendance-gate.md)
