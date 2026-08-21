# P10 talent-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-talent-api`、`../pf-talent-web` |
| 設計 | [talent-platform/DESIGN.md](../talent-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |
| ゲート | [docs/07-talent-gate.md](../talent-platform/docs/07-talent-gate.md) **Go**（Risk Accept あり） |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P10** |
| 元アイデア | 27 求人マッチング基盤 |
| 役割 | 架空 IT 求人の検索・応募・ステータス。P05 面接枠／P07 類似求人をクライアント利用 |
| 構成 | `pf-talent-api`（Hono/Node、FTS 内蔵）、`pf-talent-web`（Next、`:3011`）。`pf-talent-search` は作らない |

求人の正は RDB。検索インデックスは Postgres `tsvector` + `pg_trgm`（単体テスト時は部分一致）。スクレイピングしない。

---

## 2. 目的・スコープ

**目的:** 就職活動ドメインで検索品質（フィルタ・ファセット・日本語）と応募状態機械を見せる。本番 ATS 置き換えではない。

**含む:** 企業求人 CRUD（draft/published）、候補者プロフィール、応募スナップショット、状態遷移、検索・ファセット、保存検索 run、通報、P05 面接枠／booking webhook、P07 類似＋events（任意）、org 境界（雇用主求人）、dev-auth / OIDC、Compose と overlay C（staging 含む）。

**技術:** API は TypeScript（Hono）、Web は Next.js、DB は PostgreSQL（空なら memory）、認証は `X-Dev-User-*` または P01 Bearer（JWT/userinfo + `org_id`）。

---

## 3. 実装済み機能

### 3.1 API（Compose ホスト `:8091` → コンテナ 8090）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health` `/ready` | liveness |
| GET | `/v1/jobs` | 公開求人検索（`q`, `employmentType`, `remote`, `skills`, `salaryMin`/`Max`） |
| GET | `/v1/jobs/facets` | 件数ファセット |
| GET | `/v1/jobs/:id` | 詳細（recommend view event 任意） |
| GET | `/v1/jobs/:id/similar` | P07 または skill overlap（`source`: recommend｜fallback） |
| POST | `/v1/jobs` | 求人作成（employer + org） |
| GET | `/v1/employers/:sub/jobs` | 雇用者一覧（draft 含む） |
| POST | `/v1/jobs/:id/applications` | 応募（履歴書スナップショット） |
| GET | `/v1/jobs/:id/applications` | 雇用者向け応募一覧（ACL） |
| GET | `/v1/candidates/:sub/applications` | 候補者向け |
| GET | `/v1/applications/:id` | 詳細 |
| PATCH | `/v1/applications/:id/status` | 状態機械（不正は 409） |
| GET | `/v1/applications/:id/interview-slots` | P05 公開枠（`document_passed`／`interview`） |
| PUT | `/v1/applications/:id/calendar-link` | `externalRef` |
| POST | `/v1/jobs/:id/provision-interview-event-type` | P05 イベントタイプ準備 |
| POST/GET | `/v1/saved-searches*` | 保存検索・run |
| PUT/GET | `/v1/profiles/:sub` | 候補者プロフィール |
| POST/GET | `/v1/reports` | 通報（一覧は open） |
| POST | `/v1/dev/seed` | 架空デモ求人 |
| POST | `/webhooks/calendar` | `calendar.booking.confirmed` → 応募を `interview` |

**応募遷移:** `applied` → `document_passed`｜`rejected` → `interview`｜`rejected` → `offered`｜`rejected`。

### 3.2 Web（`:3011`）

| 画面 | パス |
| --- | --- |
| ユーザー選択／検索 | `/`（`?user=` 必須。ゲストなし） |
| 求人詳細・応募 | `/jobs/[id]` |
| プロフィール／応募／保存検索 | `/me/profile`、`/me/applications`、`/me/saved-searches` |
| 企業求人・応募者 | `/employer/jobs`、`.../new`、`.../[id]/applications` |
| 通報管理 | `/admin/reports` |
| OIDC | `/login` `/callback` `/logout` `/logged-out`（Issuer 設定時） |
| プローブ | `/health` `/ready` |

OrgSwitcher + `X-Dev-User-Org`／OIDC `org_id`。カレンダー未接続時は枠が「カレンダー未接続」。

### 3.3 無いもの（意図的または未着手）

OpenSearch、メッセージング、地図、課金・掲載プラン、ATS 課題管理（→ P04）、実メール送信、スキルマスタ正規化 UI、OpenAPI 機械可読（docs `05-api.md` が正）。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 開発 | `TALENT_DEV_AUTH≠false` で `X-Dev-User-Sub` / `X-Dev-User-Org`（既定 org `org-demo-a`） |
| OIDC | Bearer。`org_id` 必須（JWT claim または userinfo）。staging/production は `TALENT_DEV_AUTH=false` + `OIDC_ISSUER` 必須 |
| カレンダー | `CALENDAR_INTERNAL_TOKEN` + `CALENDAR_API_URL` |
| 推薦 | 任意 `RECOMMEND_API_URL`（失敗時 skill fallback。events は best-effort） |

**テナント:** 求人は `jobs.org_id`。候補者プロフィール／保存検索は `sub` 単位。応募一覧は当事者以外 403。

**主要 env:** `TALENT_ENV`、`TALENT_HTTP_PORT`、`TALENT_DATABASE_URL`、`TALENT_DEV_AUTH`、`OIDC_*`、`CALENDAR_*`、`RECOMMEND_API_URL`。Web: `TALENT_API_URL`、`OIDC_*`。

---

## 5. デモ起動

```powershell
cd pf-talent-api/deploy
copy .env.example .env
docker compose up -d --build
# Web
cd pf-talent-web/deploy
copy .env.example .env
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:8091/health | API |
| http://localhost:3011/?user=candidate-1 | 候補者 |
| http://localhost:3011/?user=employer-1&role=employer | 企業 |
| localhost:5436 | Postgres（ユーザー／DB `talent`） |

K8s: `pf-cloud-k8s` overlay **`c-scheduling-talent`**（+ staging）。単体 apply 禁止。ホスト: `talent.localhost` / `talent-api.localhost`。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P01 | クライアント `pf-talent-web`。redirect `http://localhost:3011/callback`。OIDC 時 `org` scope |
| P05 | employer `sub` がホスト。イベントタイプ／`externalRef` と応募の `calendarExternalRef` 一致。webhook `calendar.booking.confirmed` |
| P07 | namespace=`jobs`。similar GET、view/apply events POST |
| P13 | 個人を含まない集計のみエクスポート可（文書上） |

---

## 7. 非目標・名乗らないこと

実在求人クローリング、課金プラン、ATS 全機能、社内人事マスタ正本、労基・給与計算、本番採用サイト置き換え。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点・文書／設計ベース） |
| --- | --- |
| `pf-talent-api` `npm test` | 単体＋Postgres 結合（接続時のみ） |
| staging overlay / cluster smoke | **Pass**（DEV_AUTH 拒否、health） |
| バックアップ実演 | **Pass**（docs/08） |
| Talent path ゲート | **Go**（Risk Accept: 採用フル E2E、org 深さ、recommend 任意） |
| 書類 | docs 一式あり。`05-api.md` はコード追随が必要箇所あり |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | アイデア 27 のメッセージング・地図・ソート（年収）は薄い／未実装 | 検索フィルタが本領 |
| 2 | スキルタグ正規化マスタなし | DESIGN 注意点のまま |
| 3 | recommend は任意。障害時フォールバックを名乗る必要 | ゲート Risk Accept |
| 4 | staging 専用ログイン→応募 E2E 未 | Risk Accept。手動手順は [21-talent-staging.md](../21-talent-staging.md) |
| 5 | Compose デモは `?user=`。overlay C は Web OIDC 必須 | `.env.example` コメントどおり |
| 6 | ~~docs のシード件数表現と空ストア 10 件シード~~ → 約 10 件に追随 |
| 7 | OpenAPI 機械可読なし | 人間向け `05-api.md` |

---

## 10. 根拠パス

- メタ: `portfolio-plan/talent-platform/DESIGN.md`、`docs/*`、`talent-platform/AGENTS.md`、`portfolio-idea/27-*.md`
- 製品: `pf-talent-api/src/app.ts`、`auth.ts`、`domain.ts`、`deploy/compose.yaml`、`pf-talent-web/app/**`
- 連携: `pf-cloud-k8s/deploy/overlays/portfolio-integration-c-scheduling-talent*`、`scripts/cluster-smoke-c-scheduling-talent*.ps1`
