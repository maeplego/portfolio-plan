# P16 payroll-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-payroll` |
| 設計 | [payroll-platform/DESIGN.md](../payroll-platform/DESIGN.md) |
| 方針正本 | [payroll-tax-policy.md](../payroll-platform/payroll-tax-policy.md) |
| 優先 | コード・テスト → DESIGN／tax-policy →（docs はデモ後） |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P16** |
| 元アイデア | **無し**（商用ロードマップ由来の第 16 製品） |
| 役割 | 法人向け給与**連携ポート＋薄いデモ明細**。勤怠（P09）と個人家計（P14）から分離 |
| 構成 | モノレポ相当の単一 TS サービス（Hono API + 同一プロセス HTML UI）、メモリ store、`deploy/k8s/` |
| 状態 | **デモ段階**（P16-規制名乗り 前）。空の `docs/` は作らない方針 |

就活カタログ P01–P15 とは別枠の工学 ID。カタログに「給与できます」と書くのは規制名乗りゲート Go まで禁止。

---

## 2. 目的・スコープ

**目的:** P09 `minutes-v1` CSV（金額なし）を受け、モック給与／会計 SaaS へ渡し、フィクション時給で明細プレビューを見せる。法令準拠エンジンではない。

**含む（デモ段階）:** Attendance CSV import、`PayrollExportPort`／`AccountingPort` モック、demo rates、明細 UI（免責常時）、disclaimer API、staging ENV ガード、f-ops-staging 入口。

**含まない（規制名乗り前）:** 源泉・社保・年末調整・振込確定の準拠計算、電子申告本線、マイナンバー本保管、フル ERP。

---

## 3. 実装済み機能

### 3.1 HTTP API（既定 `:8020`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/` | 明細プレビュー UI（免責バナー常時） |
| GET | `/health` `/ready` | 生存 |
| GET | `/v1/disclaimer` | `legalEffect: false` + 契約名 `minutes-v1` |
| POST | `/v1/imports/attendance-csv` | P09 CSV。`?month=` 任意。表示名 strip 可 |
| GET/PUT | `/v1/demo-rates` | フィクション時給（`demoYenPerHour`） |
| GET | `/v1/statements/preview` | 分×時給の **fiction gross**（税控除なし） |
| POST | `/v1/exports/payroll` | モック給与 SaaS（タイムシート行渡し） |
| POST | `/v1/exports/accounting` | モック会計（**分数量**。円ではない） |

**明細計算:** `demoGrossYen = floor(workMinutes/60 * demoYenPerHour)`。税率表・賃金規程ではない。応答に常に `legalEffect: false` / disclaimer。

### 3.2 Ports / アダプタ

| Port | 実装 | 意味 |
| --- | --- | --- |
| `PayrollExportPort` | `MockPayrollExportAdapter` | freee／奉行系の**置き場**の見本 |
| `AccountingPort` | モック仕訳（分） | 金額会計ではない |

### 3.3 無いもの（意図的）

- 源泉徴収票・年末調整・振込データ・e-Tax
- 実賃金表・法定税率表のハードコード「準拠」
- Postgres 永続（メモリ store）
- 本物の OIDC JWT 検証（Bearer はラボ用スタブ。staging では DEV_AUTH 拒否）
- `docs/01–06`（デモ塊後・規制名乗り前は増やさない）
- GitHub Actions CI ワークフロー（リポ内に無し。`npm test` ローカル）

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| development | `PAYROLL_DEV_AUTH` 既定 true → `X-Dev-User-Sub` + 任意 `X-Dev-User-Org` |
| staging/production | `PAYROLL_DEV_AUTH` 必須 false。`PAYROLL_OIDC_ISSUER`（または `OIDC_ISSUER`）必須 |
| Bearer（非 DEV） | トークン非空なら通すスタブ（`sub: bearer-user`）。**本実装の OIDC verify は未** |
| テナント | `orgId` 単位で import／rates を保持 |

**主要 env:** `PAYROLL_ENV`、`PAYROLL_DEV_AUTH`、`PAYROLL_HTTP_PORT`、`PAYROLL_OIDC_ISSUER`、`PAYROLL_STRIP_DISPLAY_NAME`。

免責文（実装）: Demo / portfolio only. No legal payroll, tax, or labor-law compliance. Do not use with real employee payroll data under the evaluation license.

---

## 5. デモ起動

```powershell
cd pf-payroll
npm install
npm test
npm run dev   # http://127.0.0.1:8020/
```

P09 の `GET /v1/months/{month}/export.csv`（契約 `minutes-v1`）を UI または `POST /v1/imports/attendance-csv` に渡す。

**Staging:** `pf-cloud-k8s` の `docker-desktop-f-ops-staging`（`payroll.localhost`）。手順は `portfolio-plan/24-payroll-staging.md`。確認: DEV_AUTH のみの export は **401**。

デモ観点:

1. UI に免責が常時
2. CSV → preview に fiction gross ¥
3. `legalEffect: false`

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P09 | **入力ソース**。`minutes-v1` CSV。**金額列なし**。給与ロジックを P09 に載せない |
| P01 | OIDC／org（BYO 可）。staging で issuer 必須 |
| P14 | **参照しない・バンドル禁止**（個人家計 ≠ 法人給与） |
| P13 | 分析受け皿候補。給与本番の偽ソースにしない |
| P03 | 帳票 PDF 添付は将来任意 |
| カタログ | P16-規制名乗り Go まで「給与できます」非掲載 |

推奨 SKU: Attendance + Foundation が今すぐ。Backoffice path（P16+P01+P09）は規制名乗り後。

---

## 7. 非目標・名乗らないこと（最重要）

- 労基・税務・社保の「準拠」「法令対応済み」
- 源泉・年末調整・振込確定・電子申告本線
- マイナンバーの本保管
- フル自前 ERP／給与エンジンを先に書くこと
- P09 への金額カラム追加、P14 への法人給与混入
- 評価 LICENSE のまま実在従業員の本番給与運用
- 実在の給与・税務データをデモに入れること

規制名乗りは税理士／社労士レビュー後の**別ゲート**（`payroll-tax-policy.md` の P16-規制名乗り）。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `npm test`（vitest） | 明細 fiction・MN1（staging で DEV_AUTH 拒否）等 |
| GitHub Actions | **ワークフロー無し**（監査時点） |
| K8s | `deploy/k8s` + cloud-k8s f-ops-staging smoke |
| 書類 | DESIGN + tax-policy + staging 手順。製品 `docs/` 空のまま |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | Bearer OIDC がスタブ | staging は DEV_AUTH 拒否のみ強い。本検証は backlog 推奨 |
| 2 | 永続化なし（メモリ） | デモ段階として意図的 |
| 3 | 製品 docs 01–06 未 | 方針どおりデモ後。規制名乗り前に無理に増やさない |
| 4 | CI workflow 未整備 | 他 pf-* と比べて薄い |
| 5 | バックアップ手順テンプレ | tax-policy 上任意未完 |
| 6 | 顧客向け一文「給与は P16／当面 SaaS」 | 方針チェック未 |
| 7 | preview の円は fiction | 面接・提案で「計算できる」＝準拠と誤解させない |

---

## 10. 根拠パス

- メタ: `portfolio-plan/payroll-platform/DESIGN.md`、`payroll-tax-policy.md`、`24-payroll-staging.md`、`payroll-platform/AGENTS.md`、`11-implementation-backlog-by-pxx.md`
- 製品: `pf-payroll/README.md`、`src/app.ts`、`statement.ts`、`disclaimer.ts`、`auth.ts`、`adapters/*`、`deploy/k8s/`
- 連携: `pf-cloud-k8s` f-ops / f-ops-staging overlays
