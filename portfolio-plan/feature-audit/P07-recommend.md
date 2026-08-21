# P07 recommend — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-recommend` |
| 設計 | [recommend/DESIGN.md](../recommend/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P07** |
| 元アイデア | 20 レコメンドエンジン |
| 役割 | 学習ジョブと低レイテンシ推論の **共通推薦エンジン**（EC／求人／映画は namespace で分離） |
| 構成 | `apps/api`（FastAPI）、`apps/train`（バッチ CLI）、`apps/demo-web`、`packages/metrics`・`schemas`・`runtime`、`testdata/`、`deploy/` |

P06／P10 が各自 pickle を持たないための共有能力。本番レコメンド置き換えではない。

---

## 2. 目的・スコープ

**目的:** オフライン評価まで含む学習可能な推論 API。ドメイン差はデータセットとアイテムメタで吸収し、HTTP 形は共通。

**含む:** 人気ベース＋item-item cosine、時間 split 評価、コールドスタートフォールバック、ファイル registry（`manifest.json`）、MovieLens／jobs／commerce フィクスチャ、demo-web、P06／P10 向け契約テスト。

**技術:** Python 3.12+、FastAPI、pandas、Compose で train→api→web。Postgres／MinIO／Redis キャッシュは未接続（DESIGN 上は将来）。

---

## 3. 実装済み機能

### 3.1 推論 API（`:8098`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health` | liveness |
| GET | `/ready` | 学習済み namespace が無ければ 503 |
| GET | `/v1/models` | version・cutoff・n_users／n_items・metrics・sample_user_ids |
| GET | `/v1/recommend?namespace=&user_id=&k=` | ユーザー向け。未知ユーザーは popularity、`fallback: true`。k 既定 10・最大 50 |
| GET | `/v1/similar-items?namespace=&item_id=&k=` | 類似。未知 item は 404（呼び出し側フォールバック用） |
| POST | `/v1/events` | JSONL 追記のみ。**オンライン学習しない** |

**namespace（実装・学習）:** `movies`、`jobs`、`commerce`。

### 3.2 学習（CLI／Compose one-shot）

- 時間ベース split。人気 vs item-item の Recall@K／NDCG@K
- Compose `recommend-train` が `ml-tiny`＋`jobs-tiny`＋`commerce-tiny` を書き、API が volume から読む
- 公開 MovieLens `ml-latest-small` は学習時 DL 可（Git 非配置）
- HTTP `/train` は置かない。ホットスワップは manifest mtime 監視

### 3.3 demo-web（`:3008`）

namespace／ユーザー切替、recommend・similar、メトリクス表示。CORS は `RECOMMEND_CORS_ORIGIN`。

### 3.4 無いもの（意図的または未接続）

認証必須、リアルタイム学習、大規模 ANN、Postgres／MinIO registry、Redis キャッシュ、多様性制御、オンライン A/B。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 推論 API | **認証なし**（利用側 BFF が保護） |
| 学習 | CLI／Compose ジョブのみ（公開 HTTP なし） |

**テナント:** なし。ユーザー ID 空間は namespace 内で閉じる。P01 `sub` と MovieLens 数値 ID を混ぜない。

**主要 env:** `RECOMMEND_HTTP_PORT`、`RECOMMEND_MODELS_DIR`、`RECOMMEND_CORS_ORIGIN`。呼び出し側は `RECOMMEND_API_URL`。

---

## 5. デモ起動

```powershell
cd deploy
copy .env.example .env
docker compose --env-file .env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3008 | デモ UI |
| http://localhost:8098/health | API |
| http://localhost:8098/docs | OpenAPI |

デモ観点: ユーザー切替でリスト変化、メトリクス表、未知ユーザーで `fallback: true`。

K8s: `pf-recommend/deploy/k8s` は commerce／talent overlay から参照。単体 apply 禁止。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| **P06** commerce | BFF が `namespace=commerce` で recommend／similar。item_id＝SKU。失敗・空・未マップはカタログ順。events POST 任意 |
| **P10** talent | `GET /v1/similar-items?namespace=jobs`。未知 item 404 → skill overlap。CF がローカル overlap より弱ければ出さない |
| P01 | 直接結合なし（ID は呼び出し側が決める） |

---

## 7. 非目標・名乗らないこと

本番レコメンド置き換え、リアルタイム学習、巨大 ANN クラスタ、求人・EC・映画の単一埋め込み空間、巨大 npy の Git 管理、商用精度保証。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| `python -m pytest` | 契約・学習・ホットスワップ・メトリクス（CI 本線） |
| CI | pytest、pip-audit、Trivy、kustomize、compose config |
| Compose 起動 | CI 外（ローカル／レビュー） |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | 推論 API がオープン | 商用時はネットワーク／ゲートウェイ側で保護必須 |
| 2 | Postgres／MinIO／Redis 未接続 | DESIGN の保存層はファイル registry のみ |
| 3 | レイテンシ SLO・再学習 runbook は backlog 推奨 | 測定コードはあるが運用文書は薄い |
| 4 | events JSONL は再学習に自動接続されない | 手動再 train |
| 5 | ランダム split は未実装 | 時間 split のみ（DESIGN どおり） |

---

## 10. 根拠パス

- メタ: `portfolio-plan/recommend/DESIGN.md`、`docs/*`、`recommend/AGENTS.md`、`portfolio-idea/20-*.md`
- 製品: `pf-recommend/apps/api/src/recommend_api/main.py`、`apps/train`、`deploy/compose.yaml`、`tests/test_api.py`
- 連携: `pf-commerce/apps/bff/src/server.js`、`pf-talent-api/src/app.ts`
