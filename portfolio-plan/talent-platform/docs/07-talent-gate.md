# Talent path ゲート自己監査

| 項目 | 値 |
| --- | --- |
| 対象 | P10 Talent + P05 Calendar（± P01）。人事マスタ正本・労基は名乗らない |
| 監査日 | 2026-08-21 |
| 判定 | **Go（Risk Accept: 採用フル E2E 未・recommend 任意）** |

Collab / Commerce と同じゲート枠（[production-definition.md](../../production-definition.md)）。Talent は「求人マッチング PoC」まで。

## チェックリスト

### 認証

- [x] **Yes** — `TALENT_ENV=staging` で DEV_AUTH 起動拒否
- [x] **Yes** — `CALENDAR_ENV=staging` で DEV_AUTH 起動拒否
- [x] **Yes** — staging overlay（`docker-desktop-c-scheduling-talent-staging`）
- [x] **Yes** — cluster smoke: Talent `POST /v1/jobs` + `X-Dev-User-Sub` → **401**（2026-08-21）

### テナント／データ

- [x] **Yes** — 秘密は Secret / env のみ
- [x] **Yes** — バックアップ実演（[08-backup-restore-drill.md](08-backup-restore-drill.md)）
- [ ] **Risk Accept** — 顧客人事マスタ正本・RLS 深さは PoC 契約で確認
- [x] **Yes** — 労基・給与計算は名乗らない（カタログ／DESIGN どおり）

### 品質・運用

- [x] **Yes** — unit 緑、staging smoke Pass
- [x] **Yes** — `/health`（talent / calendar Ingress）
- [ ] **Risk Accept** — ログイン→求人→応募の staging 専用 E2E は未（デモ overlay 依存）
- [ ] **Risk Accept** — P07 recommend は任意経路。失敗時フォールバックを名乗る

## サマリ

| 判定 | **Go（Talent path PoC 可。労基・人事正本なし）** |
| --- | --- |
| ブロッカー | なし |
| Risk Accept | staging 専用採用 E2E、org 隔離の深さ、recommend 依存 |
| 注意 | 評価 LICENSE のまま実人事データ本番は No-Go |

## 関連

- [talent-staging.md](../../talent-staging.md)
- [commercial-roadmap.md](../../commercial-roadmap.md)
- [implementation-backlog-by-pxx.md](../../implementation-backlog-by-pxx.md)
