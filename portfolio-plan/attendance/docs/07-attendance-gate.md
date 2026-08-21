# Attendance ゲート自己監査

> **読者**: 商用ゲート・運用向け。採用スキムは [HIRING.md](../../HIRING.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P09 Attendance（± P01）。労基・給与計算は名乗らない |
| 監査日 | 2026-08-21 |
| 判定 | **Go（Risk Accept: 打刻フル E2E 未・org 深さ）** |

Collab / Commerce / Talent と同じゲート枠（[production-definition.md](../../production-definition.md)）。Attendance は「打刻・月次カレンダー PoC」まで。

## チェックリスト

### 認証

- [x] **Yes** — `ATTENDANCE_ENV=staging` で DEV_AUTH 起動拒否
- [x] **Yes** — staging overlay（`docker-desktop-f-ops-staging`）
- [x] **Yes** — cluster smoke: `POST /v1/punches` + `X-Dev-User-Sub` → **401**（2026-08-21 Quick）

### テナント／データ

- [x] **Yes** — 秘密は env / Secret のみ
- [x] **Yes** — バックアップ実演（[08-backup-restore-drill.md](08-backup-restore-drill.md)）
- [ ] **Risk Accept** — org 隔離の深さは顧客 PoC 前に確認
- [x] **Yes** — 労基・給与計算は名乗らない（カタログ／DESIGN どおり）

### 品質・運用

- [x] **Yes** — unit 緑、staging smoke Pass
- [x] **Yes** — `/health` `/ready`（API Ingress）
- [ ] **Risk Accept** — ログイン→打刻の staging 専用 E2E は未（デモ overlay の DEV_AUTH 打刻に依存）

## サマリ

| 判定 | **Go（Attendance PoC 可。労基なし）** |
| --- | --- |
| ブロッカー | なし |
| Risk Accept | staging 専用打刻 E2E、org 隔離の深さ |
| 注意 | 評価 LICENSE のまま実勤怠本番は No-Go |

## 関連

- [attendance-staging.md](../../attendance-staging.md)
- [commercial-roadmap.md](../../commercial-roadmap.md)
- [implementation-backlog-by-pxx.md](../../implementation-backlog-by-pxx.md)
