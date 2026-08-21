# P09 attendance — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-attendance` |
| 設計 | [attendance/DESIGN.md](../attendance/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P09** |
| 元アイデア | 03 勤怠・工数管理 |
| 役割 | 打刻・申請・承認・月次締め・工数按分の **モジュールモノリス**（SIer／業務カード用 Java） |
| 構成 | `apps/api`（Spring Boot）、`apps/web`（Next）、`deploy/`（Postgres＋両者） |

P05 予約とは統合しない。金額・給与計算なし。労基法準拠の名乗りなし。

---

## 2. 目的・スコープ

**目的:** 日本の業務システムで頻出する勤怠フローを正確に実装する。ポートフォリオ内で Java／Spring の別カード。

**含む:** 従業員マスタ、打刻（順序・整数分・Asia/Tokyo）、日次／月次サマリー、修正・休暇申請と承認、工数按分、月次締め、CSV／PDF、未打刻一覧、org 期間設定（anchor／closeByDay）、勤務プロファイル・事後打刻・休暇区分、SES 段階 A–C（engagement／worksite、handoff CSV、visible-members）、P01 OIDC（任意）／dev-auth。

**技術:** Java 21、Spring Boot、JPA、Next.js、PostgreSQL。DESIGN の `apps/batch` は独立アプリとしては未分離（リマインドは API 一覧）。

---

## 3. 実装済み機能

### 3.1 運用・自分

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health`、`/ready` | liveness／DB |
| GET | `/v1/me` | sub、role、engagement、worksite*、zone |
| GET | `/v1/me/daily-summary` | 当日（任意 date）打刻と労働分 |
| GET | `/v1/me/month-summary?month=` | 月次カレンダー用 |
| PUT | `/v1/me/provisional-days` | closeByDay 以降の見込み入力 |

### 3.2 打刻・スケジュール

| メソッド | パス | 内容 |
| --- | --- | --- |
| POST | `/v1/punches` | `clock_in`／`out`／`break_*`。任意 `workDate`＋`at`（事後打刻） |
| POST | `/v1/me/days/{date}/apply-schedule` | 所定の出・休・退を一括 |

順序違反・締め後は 409。サーバー時刻が正（クライアント `punchedAt` 無視）。夜勤なし。

### 3.3 ワークフロー

| メソッド | パス | 内容 |
| --- | --- | --- |
| POST/GET | `/v1/requests` | 申請（休暇 `leaveKind`: paid／am_half／pm_half／absence 等） |
| GET | `/v1/approvals` | 上長 inbox |
| POST | `/v1/requests/{id}/decision` | 承認／却下 |
| POST/GET | `/v1/allocations` | 工数按分（合計 ≤ 勤務） |
| POST | `/v1/months/{month}/close` | 上長締め |
| GET | `/v1/reminders/unpunched?date=` | 未打刻一覧（メールなし） |

### 3.4 CSV／PDF／org 設定

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/v1/months/{month}/export.csv` | プロファイル切替。ヘッダ `X-Attendance-Export-Contract` |
| GET | `/v1/months/{month}/timesheet.pdf` | タイムシート PDF |
| GET/PUT | `/v1/org/period-settings` | `periodAnchorDay`、`closeByDay`、CSV 既定、所定時刻・休憩 |
| GET | `/v1/org/csv-profiles` | カタログ |

**CSV プロファイル（実装）:**

| id | 性質 |
| --- | --- |
| `minutes-v1` | P16 向け既定（engagement／worksite 列含む） |
| `erp-generic-ja` | 非公式例示 |
| `mf-attendance-punch-v1` | MF クラウド勤怠 日次打刻（公式ヘルプ列） |
| `freee-hr-monthly-v1` | freee 月次列。**残業・休日内訳は 0** |
| `custom` | 列順カスタム |

KOT／ジョブカン／奉行の固定公式スキーマは未作成（DESIGN 調査どおり）。

### 3.5 SES／客先（段階 A–C）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/v1/months/{month}/handoff.csv` | 就業側→雇用主向け `worksite-minutes-v1` |
| POST/GET | `/v1/months/{month}/handoffs` | CSV 取り込み・receipt 一覧 |
| GET | `/v1/worksite/visible-members` | 他社ゲスト含む読み取り名簿 |

### 3.6 Web（`:3019`）

打刻ホーム、`/calendar`、`/workflow`（申請・承認・工数・締め・CSV・期間設定）、OrgSwitcher（OIDC 時）。デモユーザー: `aoki.haru`（一般）、`sato.mei`（上長）。

### 3.7 無いもの

代理打刻、給与・年末調整、IC カード、シフト最適化、メールリマインド、独立 batch アプリ、夜勤モデル、36 協定の法計算、派遣法エンジン。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 開発 | `ATTENDANCE_DEV_AUTH=true`＋`X-Dev-User-Sub`（任意 `X-Dev-User-Org`） |
| OIDC | API: `ATTENDANCE_OIDC_*`。Web: `OIDC_*`＋BFF。`org` scope／`org_id` |
| staging+ | `ATTENDANCE_ENV` で OIDC 強制（CommercialProfile） |

**テナント:** `org_id`。従業員・締め・設定は org 境界。

**主要 env:** `ATTENDANCE_STORE`、`ATTENDANCE_DEV_AUTH`、`ATTENDANCE_SEED_DEMO`、`ATTENDANCE_DATASOURCE_*`、`ATTENDANCE_CORS_ORIGIN`、OIDC 一式、web の `ATTENDANCE_API_URL`／`NEXT_PUBLIC_ATTENDANCE_API_URL`。

---

## 5. デモ起動

```powershell
copy deploy\.env.example deploy\.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3019 | 打刻 |
| http://localhost:3019/calendar | 月次 |
| http://localhost:3019/workflow | 申請・締め・CSV |
| http://localhost:8019/health | API |

デモ: 打刻順序、休憩控除分、ユーザー切替で他人の打刻が見えない、締め後 409、工数超過 400、上長のみ CSV。

AWS 3-tier は **P02 `pf-cloud-aws`（env は P09 向け）** で Compose デモとは別経路。`terraform apply` は非目標。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| **P01** | `sub`↔従業員。OIDC 時 org。Compose 既定は dev-auth |
| **P16** payroll | `export.csv` 契約 **`minutes-v1`**（金額列なし）。期間ラベルは period 定義に従う |
| **P13** | PII なし集計エクスポートのみ許可（直接結合は薄い） |
| **P02** | AWS 3-tier 載せ先候補。K8s overlay もあり |
| **P05** | 連携非目標 |

---

## 7. 非目標・名乗らないこと

給与計算・年末調整、労基法／36 協定／派遣法の準拠、IC カード、シフト最適化、客先と雇用主の給与を同一テナントで混ぜること、本番勤怠 SaaS 置き換え。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `mvn test`（`apps/api`） | 日付境界・打刻・ワークフロー・CSV ベンダー等（CI） |
| CI | Maven test、Trivy、kustomize、compose config |
| ゲート書類 | `docs/07-attendance-gate.md`、バックアップ実演 Pass（backlog） |
| Web E2E OIDC | backlog 推奨。staging 打刻 E2E は Risk Accept |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | README は「代理打刻なし」と一致。DESIGN 注意の代理打刻は未実装 | |
| 2 | `docs/05-api.md` が 2026-08-19 時点で薄い | period／CSV ベンダー／handoff／事後打刻がコード先行 |
| 3 | freee CSV の OT 内訳は常に 0 | 名乗らないこととセットで説明 |
| 4 | WebConfig CORS の allowedHeaders が `X-Dev-User-Sub` 中心 | Org ヘッダは確認余地 |
| 5 | 独立 `apps/batch` なし | リマインドは API 一覧のみ |
| 6 | OpenAPI 未生成 | DESIGN の「api が出して web が生成」は未達 |
| 7 | 夜勤なし | 勤務日＝Tokyo 暦日の打刻時刻 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/attendance/DESIGN.md`、`docs/*`、`attendance/AGENTS.md`、`portfolio-idea/03-*.md`
- 製品: `pf-attendance/apps/api/src/main/java/com/pf/attendance/api/*.java`、`app/export/VendorCsvFormats.java`、`deploy/compose.yaml`、`apps/web`
- 連携: `pf-payroll`（minutes-v1）、`pf-cloud-aws`（3-tier）、`pf-identity`（OIDC）
