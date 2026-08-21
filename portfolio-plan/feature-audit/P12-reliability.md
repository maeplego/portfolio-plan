# P12 reliability-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-reliability`（モノレポ） |
| 設計 | [reliability-platform/DESIGN.md](../reliability-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P12** |
| 元アイデア | 04 インシデント管理、30 SRE ランブック＋障害シミュレーター |
| 役割 | 「今の障害」と「判断の練習」を同一 UX／サービスマスタで扱う |
| 構成 | `apps/api`（Go）、`apps/web`（Next）、`packages/scenario`、`packages/openapi`、`deploy/` |

観測（P02）や EC（P06）を壊す自動修復は実装しない。訓練は仮想メトリクスのみ。

---

## 2. 目的・スコープ

**目的:** インシデント画面 ↔ ランブック ↔ 訓練クリア後の同じランブック、を相互に見せる学習デモ。PagerDuty 完全互換ではない。

**含む:** サービスマスタ、インシデント CRUD／Ack／Resolve／コメント、HMAC webhook＋dedup、デモアラート、仮想メトリクス、訓練採点（3 シナリオ）、ランブック CRUD、オンコール一覧（架空）、Compose＋overlay F（および d-commerce に画像あり）。

**技術:** Go API、Next Web、PostgreSQL。ジョブ用 Redis／実 Slack 通知は未／なし。認証は **開発ヘッダのみ**（OIDC 未配線。起動は `RELIABILITY_DEV_AUTH=true` 必須）。

---

## 3. 実装済み機能

### 3.1 API（Compose `:8012`）

| メソッド | パス | 認可 | 内容 |
| --- | --- | --- | --- |
| GET | `/health` `/ready` | なし | ready は Postgres ping |
| GET | `/v1/services` `/v1/services/{id}` | なし | 監視対象マスタ |
| GET | `/v1/virtual-metrics` | なし | 訓練用仮想時系列（`?after=`） |
| GET | `/v1/incidents` `/v1/incidents/{id}` | なし | 一覧・詳細（デモ） |
| POST | `/v1/incidents` | `X-Dev-User-Sub` | 手動起票 |
| POST | `/v1/incidents/{id}/ack` | 同上 | `acknowledged` |
| POST | `/v1/incidents/{id}/resolve` | 同上 | `resolved`（triggered から直接可） |
| POST | `/v1/incidents/{id}/comments` | 同上 | タイムライン |
| POST | `/v1/demo/alerts` | 同上 | 擬似 inventory 5xx 起票 |
| POST | `/v1/integrations/{key}/events` | HMAC `X-Signature-256` | 外部イベント。dedup／`event_id` 冪等 |
| GET | `/v1/training/scenarios` | なし | シナリオ名一覧 |
| POST | `/v1/training/score` | なし | `{ actions }` 採点。未知操作 400 |
| GET | `/v1/training/history` | なし | 訓練履歴 |
| GET/POST/PUT/DELETE | `/v1/runbooks*` | 書込は dev-auth | ランブック CRUD |
| GET | `/v1/oncall` | なし | 架空オンコール（`?at=`） |

**状態機械:** `triggered` → `acknowledged` → `resolved`。resolved への ack は 409。同一未解決 `dedup_key` は集約（`alertCount`）。

**訓練アクション許可リスト:** observe, rollback, scale, escalate, declare_resolved。

| シナリオ | 正解の方向 |
| --- | --- |
| `bad-deploy`（既定） | rollback で合格。scale は減点／非回復 |
| `noisy-neighbor` | scale で回復 |
| `dependency-timeout` | escalate で回復 |

### 3.2 Web（`:3012`）

- インシデントボード、詳細（ack／resolve／コメント／デモアラート）
- `/training` — 仮想メトリクス＋操作採点。「本番システムは操作しません」表示
- ランブック／オンコール参照

### 3.3 無いもの（意図的）

自動 rollback ボット、実クラスタ診断／`kubectl`、P02 本番アラート配線、Slack 実送、P01 OIDC、エスカレーション遅延キュー（Redis）、PagerDuty 互換 API。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 書き込み API | `RELIABILITY_DEV_AUTH=true` + `X-Dev-User-Sub` のみ。false では書き込み不可（OIDC なし） |
| Webhook | `RELIABILITY_WEBHOOK_SECRET` + integration key |
| 読み取り一覧 | 認証なし（デモ） |

**テナント:** 単一デモ DB。org 境界なし。

**主要 env:** `RELIABILITY_HTTP_PORT`、`RELIABILITY_DEV_AUTH`、`RELIABILITY_CORS_ORIGIN`、`RELIABILITY_WEBHOOK_SECRET`、`RELIABILITY_INTEGRATION_KEY`、`RELIABILITY_DATABASE_URL`、`NEXT_PUBLIC_RELIABILITY_API_URL`。

---

## 5. デモ起動

```powershell
cd pf-reliability/deploy
copy .env.example .env
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3012 | ボード |
| http://localhost:3012/training | 訓練 |
| http://localhost:8012/health | API |
| http://localhost:8012/v1/virtual-metrics | 仮想メトリクス |

K8s: overlay **`f-ops`**（画像は `d-commerce` カタログにも含まれる）。ホスト `reliability.localhost` / `reliability-api.localhost`。単体 apply 禁止。デモアラート補助: `post-reliability-demo-alert.ps1`（本番操作なし）。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P02 | アラート JSON 形（`dedup_key` / `severity` / `service` / `summary`）は文書契約。本番配線は任意・未実装。デモは自前 `demo/alerts` |
| P06 | シナリオの物語（在庫 5xx 等）のみ。ネットワーク結合なし |
| P01 | DESIGN 上は認証予定だが **未配線**。現行は DEV_AUTH 必須スライス |

---

## 7. 非目標・名乗らないこと

自動修復ボット、実クラスタへの診断コマンド、PagerDuty 完全互換、本番インシデント管理の置き換え、公開デモでの他人ページング。

---

## 8. テスト・ゲート

| 層 | 状態 |
| --- | --- |
| `go test ./...`（api＋scenario） | README 正。採点・webhook dedup・状態機械をカバー |
| Compose | API+Web+Postgres |
| K8s | `deploy/k8s` + overlay F。DEV_AUTH 付きデモ |
| 商用バックログ | OIDC・ENV プロファイルが必須。現状デモ扱い |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | **docs/05-api.md・02-specification が古い** | 「ランブック CRUD・訓練履歴・オンコール未実装」と書くが **コードは実装済み** |
| 2 | P01 OIDC 未配線 | `RELIABILITY_DEV_AUTH=true` 必須。staging 風プロファイルなし |
| 3 | 一覧 GET が認証なし | デモ用。商用では要見直し |
| 4 | Slack／メール通知なし | README 明記。開発はログ想定の DESIGN 段階 |
| 5 | Redis エスカレーション遅延キューなし | DESIGN スタック記載のみ |
| 6 | P02 本番 webhook 未接続 | デモアラート／手動 HMAC で代替 |
| 7 | 訓練から本番操作しない文言は維持必須 | 画面・README・DESIGN 一致 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/reliability-platform/DESIGN.md`、`docs/*`（一部ドリフト）、`reliability-platform/AGENTS.md`、idea 04/30
- 製品: `pf-reliability/apps/api/internal/web/server.go`、`packages/scenario`、`apps/web`、`deploy/compose.yaml`、`deploy/k8s`
- 連携: `pf-cloud-k8s/deploy/overlays/portfolio-integration-f-ops`、`ingress-p12.yaml`
