# P14 personal-finance — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-finance` |
| 設計 | [personal-finance/DESIGN.md](../personal-finance/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P14** |
| 元アイデア | 10 家計簿 PWA |
| 役割 | オフライン入力可能な個人家計簿（整数円・同期・グラフ）。法人給与・会計ではない |
| 構成 | `apps/web`（Next PWA）、`apps/api`（Hono）、`packages/money`、`packages/sync-protocol`、`deploy/` |

P15 とはドメイン共有しない。起動の正は Compose。K8s マニフェストは ops 参照用（apply 本線ではない）。

---

## 2. 目的・スコープ

**目的:** フロント品質（PWA、IndexedDB キュー、LWW 同期、Recharts、整数円）を見せる。本番家計アプリ／銀行の置き換えではない。

**含む:** 取引 CRUD、ウォレット、カテゴリ、月次予算、レポート、CSV 入出力、繰り返し（day 1–28）、tombstone + purge、`POST /v1/sync`、アカウント削除、ダークモード、任意 P01 PKCE。

**技術:** Next.js PWA、Hono、PostgreSQL（またはメモリ）、整数円パッケージ、Playwright e2e（任意ワークフロー）。

---

## 3. 実装済み機能

### 3.1 API（`apps/api`、`:8014`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health` `/ready` | liveness / store ping |
| GET/DELETE | `/v1/me` | ユーザー／サーバーデータ削除 |
| GET/POST | `/v1/wallets` | ウォレット（初回「現金」） |
| GET | `/v1/categories` | 既定カテゴリ含む |
| GET/POST/PATCH/DELETE | `/v1/transactions`… | 取引（DELETE は tombstone） |
| GET/POST | `/v1/recurring-rules`… | 繰り返し＋月次 generate |
| POST | `/v1/tombstones/purge` | 古い tombstone 削除 |
| POST | `/v1/sync` | LWW（最大 100 件。categories/budgets 可） |
| GET/PUT | `/v1/budgets` | 月次予算 |
| GET | `/v1/reports/monthly` | カテゴリ／日次集計 |
| GET | `/v1/export.csv` | CSV 出力 |
| POST | `/v1/import` | CSV 取込（小数拒否） |

**同期規則:** 新しい `updatedAt` が勝つ。同時刻はサーバー。クライアントがサーバーより 120 秒超未来なら拒否。

### 3.2 Web（`:3014`）

- 月次レジャー、予算バー、`/reports` グラフ、CSV、ダークモード
- BFF `/api/finance/*`（ブラウザは API 直叩きしない）
- IndexedDB オフラインキュー（create/delete → 復帰で sync）
- manifest + Service Worker（シェルキャッシュ）
- 任意 OIDC: `/login` `/callback` `/logout`（httpOnly access token Cookie）

### 3.3 無いもの（意図的）

銀行 API／スクレイピング、確定申告、世帯権限、E2E 暗号化、多通貨（JPY 固定）、P15 統合、法人 ERP。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| デモ既定 | `FINANCE_DEV_AUTH=true` → `X-Dev-User-Sub`（シードは `demo`） |
| OIDC | Bearer（API）／PKCE + Cookie（Web）。`OIDC_*` |
| 隔離 | ユーザー単位。他ユーザーの取引は 404 |

**主要 env:** `FINANCE_DATABASE_URL`、`FINANCE_DEV_AUTH`、`FINANCE_CORS_ORIGIN`、`FINANCE_SEED_DEMO`、`OIDC_ISSUER`／`CLIENT_ID`／redirect 群。

---

## 5. デモ起動

```powershell
copy deploy\.env.example deploy\.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3014 | Web（Chrome ならインストール可） |
| http://localhost:8014/health | API |

デモ観点: 架空 3 ヶ月（2026-06〜08）、小数拒否、Offline → sync、CSV、アカウント削除。ユーザー欄 `other` で空データ確認。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P01 | 任意 OIDC public + PKCE。利用者キーは `sub` |
| P13 | **家計を流さない**（個人データ） |
| P15 | データストア統合しない（SSO のみ可） |
| P16 | **依存しない・混同禁止**（個人家計 ≠ 法人給与） |

---

## 7. 非目標・名乗らないこと

- 銀行接続・スクレイピング、実口座／実カード番号の扱い
- 実家計データの投入・公開
- 確定申告・税務ソフトの置き換え
- 法人会計 ERP・給与計算
- 「本番家計 SaaS」としての保証・準拠名乗り

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `npm test`（money / sync-protocol / api / web） | CI 本線 |
| Playwright e2e | 別 workflow。既定 CI では Postgres／ブラウザ本線外 |
| CI | unit、npm audit（allowlist）、Trivy、`kubectl kustomize`、`compose config` |
| Postgres 統合 | `FINANCE_DATABASE_URL` があるときのみ。無ければ skip |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | DESIGN「K8s に載せない」vs `deploy/k8s` + CI kustomize | docs は「起動の正は Compose」。apply 本線ではない |
| 2 | カタログ後続・staging ENV プロファイル | backlog 推奨 |
| 3 | E2E 暗号化未 | DESIGN 発展扱い |
| 4 | SW はシェルキャッシュのみ | オフライン正は IndexedDB キュー |
| 5 | 世帯共有権限なし | 非目標 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/personal-finance/DESIGN.md`、`docs/*`、`personal-finance/AGENTS.md`、`portfolio-idea/10-*.md`
- 製品: `pf-finance/README.md`、`apps/api/src/app.ts`、`apps/web/`、`packages/money`、`packages/sync-protocol`、`deploy/`
