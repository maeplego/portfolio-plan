# Commerce ゲート自己監査

> **読者**: 商用ゲート・運用向け。採用スキムは [HIRING.md](../../HIRING.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P06 Commerce path（モック決済。PCI 非対象） |
| 監査日 | 2026-08-21 |
| 判定 | **Go（Risk Accept: PCI 非名乗り・実カード禁止）** |

Collab のゲート正本は [production-definition.md](../../production-definition.md)。Commerce は同じ枠を再利用し、決済はモックのまま明示する。

## チェックリスト

### 認証

- [x] **Yes** — `COMMERCE_ENV=staging` で `COMMERCE_DEV_AUTH` 起動拒否（gateway / order）
- [x] **Yes** — staging overlay で OIDC 設定（`docker-desktop-d-commerce-staging`）
- [x] **Yes** — cluster smoke: `X-Dev-User-Sub` → **401**（2026-08-21）

### テナント／データ

- [x] **Yes** — org ヘッダ／クレーム経路あり（デモ org。厳密 RLS は Collab より浅い → 顧客 PoC 前に確認）
- [x] **Yes** — 秘密は env／Secret のみ
- [x] **Yes** — バックアップ実演（[08-backup-restore-drill.md](08-backup-restore-drill.md)）
- [x] **Yes** — 添付は P03 顧客バケット手順で差し替え可

### 品質・運用

- [x] **Yes** — unit（`COMMERCE_ENV`）緑、staging smoke Pass
- [x] **Yes** — `/health` `/ready`
- [ ] **Risk Accept** — 最小 E2E（ログイン→購入）はデモ overlay の同時購入スモークに依存。staging 専用 E2E は未 — 見直し: 初回有償 PoC 前
- [x] **Yes** — 決済はモック。PCI／実カードは名乗らない（カタログ明示）

## サマリ

| 判定 | **Go（Commerce PoC 可。PCI なし）** |
| --- | --- |
| ブロッカー | なし |
| Risk Accept | staging 専用購入 E2E、org 隔離の深さ（顧客要件で強化） |
| 注意 | 評価 LICENSE のまま実課金・実カードは No-Go |

## 関連

- [commerce-staging.md](../../commerce-staging.md)
- [commercial-roadmap.md](../../commercial-roadmap.md)
- [implementation-backlog-by-pxx.md](../../implementation-backlog-by-pxx.md)
