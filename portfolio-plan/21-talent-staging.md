# Talent path staging 手順

> **読者**: 商用準備・運用向け。採用スキムは [03-hiring.md](./03-hiring.md) → [05-review.md](./05-review.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | P10 Talent + P05 Calendar（± P01 / P07）商用ゲート検証の入口 |
| 最終更新 | 2026-08-21 |

デモ overlay C（`cluster-smoke-c-scheduling-talent.ps1`）は Talent API が `TALENT_DEV_AUTH=true` のままなので、**採用レビュー用スモーク**と **商用 staging** を分ける。

## 商用 staging の条件

- `CALENDAR_ENV=staging`（`CALENDAR_DEV_AUTH=false`、`OIDC_ISSUER` 必須）
- `TALENT_ENV=staging`（`TALENT_DEV_AUTH=false`、`OIDC_ISSUER` 必須）
- 秘密は Git に置かない。社内人事マスタ正本・労基は名乗らない

## Compose で組む

1. P01: `IDENTITY_ENV=staging`（Collab と同じ）
2. Calendar API: `CALENDAR_ENV=staging`、`CALENDAR_DEV_AUTH=false`、OIDC
3. Talent API: `TALENT_ENV=staging`、`TALENT_DEV_AUTH=false`、OIDC
4. 確認: `X-Dev-User-Sub` だけでは Talent 保護 API が 401

層は [06-verification.md](./06-verification.md)。ギャップは [11-implementation-backlog-by-pxx.md](./11-implementation-backlog-by-pxx.md)。

## Overlay

| Overlay | 用途 |
| --- | --- |
| `docker-desktop-c-scheduling-talent` | デモ／採用スモーク（Talent DEV_AUTH 可） |
| `docker-desktop-c-scheduling-talent-staging` | 商用 staging（ENV=staging、DEV_AUTH 禁止） |

```powershell
cd pf-cloud-k8s
.\scripts\smoke-c-scheduling-talent-staging.ps1              # kustomize + dry-run
.\scripts\cluster-smoke-c-scheduling-talent-staging.ps1      # 既定 Quick（数イメージ + SkipUnchanged）
.\scripts\cluster-smoke-c-scheduling-talent-staging.ps1 -Full # 全イメージ再ビルド
```

高速化の説明: `pf-cloud-k8s/docs/smoke-performance.md`。

L3a 記録（2026-08-21）: Talent `POST /v1/jobs` が `X-Dev-User-Sub` で **401**、`talent-api` / `calendar-api` Ingress health **pass**（イメージ再ビルド後）。

## 手動: ログイン → 求人 → 応募（staging）

自動化 E2E は無い（ゲート **Risk Accept**）。次を手で踏めば足りる。

1. staging overlay を上げる（上の `cluster-smoke-c-scheduling-talent-staging.ps1`）
2. [http://talent.localhost/login](http://talent.localhost/login) → IdP。学習用デモユーザー（foundation と同じ。メール `demo@example.test`。パスワードは overlay の `IDENTITY_SEED_DEMO_PASSWORD`）
3. 求人一覧から 1 件を開き応募（候補者として。必要なら画面の acting user / ロール表示を確認）
4. 期待: 応募が作成され、一覧に出る。`X-Dev-User-Sub` だけでは API が 401 のままであること

フル採用ジャーニー（書類通過 → 面接枠 → 予約 webhook）の自動確認はデモ overlay C の `cluster-smoke-c-scheduling-talent.ps1` 側。staging 専用の同経路 Playwright は未。**Risk Accept で Go 可**（[07-talent-gate.md](./talent-platform/docs/07-talent-gate.md)）。

ゲート: [talent-platform/docs/07-talent-gate.md](./talent-platform/docs/07-talent-gate.md)（**Go**）。バックアップ: [08-backup-restore-drill.md](./talent-platform/docs/08-backup-restore-drill.md)（**Pass**）。
