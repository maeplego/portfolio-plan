# P13 data-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-data` |
| 設計 | [data-platform/DESIGN.md](../data-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P13** |
| 元アイデア | 19 ETL / データパイプライン基盤 |
| 役割 | 架空（または任意で P06 デモ export）売上 CSV → 品質ゲート → Postgres staging → dbt marts →（任意）BI |
| 構成 | `seeds/`、`ingest/`、`transform/`（dbt）、`orchestrate/`（Dagster）、`bi/`、`deploy/`、`tests/` |

公開製品 REST API はない。実行口は Compose `pipeline`、Dagster UI、SQL。

---

## 2. 目的・スコープ

**目的:** 再現可能なバッチで「生データ → 品質失敗で mart を壊さない → KPI がシードから再現できる」を見せる。学習用 ETL。商用 DWH の置き換えではない。

**含む:** MinIO extract、CSV 検証、`ops.job_runs`、冪等フルリフレッシュ、dbt staging/marts + test、Dagster ジョブ、壊れた CSV デモ、任意 Metabase／KPI SQL、`PIPELINE_SOURCE=commerce` による P06 日次 export コネクタ。

**技術:** Python、Dagster、dbt-core、PostgreSQL、MinIO、任意 Metabase。Spark 不使用。

---

## 3. 実装済み機能

### 3.1 パイプライン経路

| 段階 | 内容 |
| --- | --- |
| extract | シード CSV（または commerce fetch）を MinIO へ → ローカル extract dir |
| validate | 必須列・整数円・channel∈{web,store} 等。失敗時 staging/marts 非更新 |
| staging | Postgres へ replace（成功時のみ） |
| transform | `dbt build` staging → marts → singular tests |
| ops | `ops.job_runs` に run_id・行数・failure_reason |

**`PIPELINE_SOURCE`:** `good`（既定）／`broken`／`commerce`。

### 3.2 dbt marts（実装）

| モデル | 内容 |
| --- | --- |
| staging | `stg_orders`, `stg_products` |
| dims / fct | `dim_product`, `dim_date`, `fct_order_items` |
| marts | `daily_sales`, `sales_by_product`（整数円） |

### 3.3 実行口（製品 HTTP API なし）

| 口 | 用途 |
| --- | --- |
| Compose `pipeline` | 一回実行、exit 0/1 |
| Dagster `:3013` | ジョブ `fictional_csv_sales` |
| Postgres `:5413` | `marts.*` / `ops.job_runs` |
| Metabase `:3313` | `--profile bi` のみ。最小は `bi/dashboards/marts_kpis.sql` |

### 3.4 無いもの（意図的／未着手）

- 公開 REST API、リアルタイム CDC、Spark
- **P10 talent 集計コネクタ**（DESIGN 上任意・未実装）
- Great Expectations（dbt test で代替）
- PII／履歴書本文をマートに載せること

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| ローカル運用 | Compose 資格情報（Postgres / MinIO） |
| commerce コネクタ | `COMMERCE_EXPORT_URL` + `X-Dev-User-Sub`（デモ ops） |
| テナント | 個人向け IdP org 対象外（overview）。単一デモ DB |

**主要 env:** `DATABASE_URL`／`PG*`、`MINIO_*`、`PIPELINE_SOURCE`、`DBT_*`、`COMMERCE_EXPORT_URL`（commerce 時）。

---

## 5. デモ起動

```powershell
cd deploy
copy .env.example .env
docker compose --env-file .env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3013 | Dagster |
| http://localhost:9113 | MinIO コンソール |
| localhost:5413 | Postgres（`data`/`data`、DB `data`） |

壊れた CSV:

```powershell
docker compose --env-file .env run --rm -e PIPELINE_SOURCE=broken pipeline
```

期待 KPI 例: `seeds/expected_kpi.json`（2026-08-01 注文 3・点数 6・売上 11500 円）。同一シード再実行は raw truncate 後リロードで二重計上しない。

K8s 本線には載せない想定（Compose 中心）。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P06 | 任意コネクタ。opaque buyer id、メールなし。**本番 EC データをソースにしたことにしない** |
| P10 | DESIGN 上は職種集計のみ・履歴書禁止。**コード未実装** |
| P14/P16 | 家計・給与をソースにしない。P16 方針でも P13 は分析受け皿候補だが給与正本にしない |
| P01 | 直接依存なし |

---

## 7. 非目標・名乗らないこと

- 会社の本番 DWH 移行・置き換え
- リアルタイム CDC / Spark 規模
- 「P06/P10 本番パイプラインが動いている」と言い切ること（デモコネクタと架空シードが正）
- 顧客本番データの勝手な複製
- 実在 PII をマートに載せること

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `python -m pytest` | CI 本線（validate / marts / Dagster graph） |
| CI | pytest、pip-audit、Trivy fs、`compose config` |
| Compose 実起動・dbt 対実 DB | ローカルデモ。毎 push の CI では起動しない |
| 書類 | `docs/01–06` あり |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | `docs/05-api.md` / `01-requirements.md` が P06 コネクタ「未実装」と記載 | **コードは `PIPELINE_SOURCE=commerce` 実装済**。文書遅れ |
| 2 | P10 コネクタ未着手 | DESIGN 任意 |
| 3 | `__init__.py` / pyproject 文言が「live P06/P10 out of scope」 | commerce デモと表現がぶれやすい |
| 4 | Metabase は任意。既定 up では起動しない | 意図どおり |
| 5 | Dagster 運用 runbook・品質メトリクス | backlog 推奨 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/data-platform/DESIGN.md`、`docs/*`、`data-platform/AGENTS.md`、`portfolio-idea/19-*.md`
- 製品: `pf-data/README.md`、`ingest/`、`transform/`、`orchestrate/definitions.py`、`deploy/compose.yaml`、`seeds/`
