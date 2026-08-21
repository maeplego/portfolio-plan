# P15 habit-tracker — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-habit-mobile`、`../pf-habit-api` |
| 設計 | [habit-tracker/DESIGN.md](../habit-tracker/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P15** |
| 元アイデア | 22 モバイル習慣トラッカー |
| 役割 | オフラインファーストの習慣記録（ストリーク・通知・任意クラウド同期）。家計簿とは別製品 |
| 構成 | **ポリレポ**: Expo モバイル（SQLite）＋薄い同期 API（Hono + Postgres） |

モバイル本体は Kubernetes に載せない。API は Compose が正で、連携デモ overlay から参照しうる。

---

## 2. 目的・スコープ

**目的:** ネイティブ寄りのクライアント（ローカル DB、日付境界、通知、ストリーク純関数）を見せる。本番習慣アプリの置き換えではない。

**含む:** 習慣 CRUD（daily / weekly）、当日チェック、ストリーク／カレンダー、統計画面（30 日）、架空シード、expo-notifications（20:00）、API 同期クライアント、任意 P01 PKCE。

**技術:** Expo + TypeScript + expo-sqlite、Hono API、PostgreSQL、domain 純関数テスト。

---

## 3. 実装済み機能

### 3.1 モバイル（`pf-habit-mobile`）

| 領域 | 内容 |
| --- | --- |
| UI | 今日、詳細／カレンダー、追加、統計 |
| DB | SQLite。ローカルが正。オフラインでも記録可 |
| ドメイン | 「今日」= ユーザー IANA TZ。毎日ストリーク／週 n 回（ISO 週） |
| 通知 | 習慣作成時 20:00 リマインド（expo-notifications） |
| 同期 | `src/sync` — pull/push（habits + logs 範囲）。dev-auth または Bearer |
| 認証 | 任意 `EXPO_PUBLIC_HABIT_OIDC_*`（redirect `pfhabit://callback`） |
| シード | 架空 5 習慣 × 30 日 |

### 3.2 API（`pf-habit-api`、`:8015`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health` `/ready` | liveness / store |
| GET | `/v1/me` | `{ id, sub }` |
| GET/POST | `/v1/habits` | 一覧／作成（未アーカイブ） |
| GET | `/v1/habits/:id` | 他人は 404 |
| GET | `/v1/habits/:id/logs?from&to` | ログ範囲 |
| PUT | `/v1/habits/:id/logs/:date` | 完了 upsert（local_date 暦日） |

専用 `/sync` バッチ API はない。モバイルが CRUD を差分 pull/push。

### 3.3 無いもの（意図的／薄い）

- 習慣の PATCH／DELETE／アーカイブ API・UI（DB に `archived` はあるが公開更新口なし）
- Watch、ソーシャルランキング、ヘルスケアやり込み
- OpenAPI 生成クライアント
- モバイルの K8s 載せ

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| API デモ | `HABIT_DEV_AUTH` + `X-Dev-User-Sub`（シード `demo`） |
| API OIDC | Bearer JWT／userinfo（`HABIT_OIDC_*`） |
| モバイル | `EXPO_PUBLIC_HABIT_API_BASE` + `DEV_SUB` または PKCE access token |
| 隔離 | ユーザー単位。他ユーザー 404 |

CORS 既定オフ（ネイティブ想定）。明示 origin 設定時のみ。

---

## 5. デモ起動

**API:**

```powershell
copy deploy\.env.example deploy\.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
# curl -H "X-Dev-User-Sub: demo" http://localhost:8015/v1/habits
```

**モバイル:**

```powershell
npm install
npx expo start
# 同期: EXPO_PUBLIC_HABIT_API_BASE / EXPO_PUBLIC_HABIT_DEV_SUB
```

デモ観点: オフラインチェック残存、ストリーク TZ、通知、任意クラウド同期。実在人物の習慣ログは入れない。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| P01 | 任意 public + PKCE（IdP seed `pf-habit-mobile`） |
| P14 | データ統合しない。SSO のみ可 |
| その他 | 習慣データを分析ソースにしない |

---

## 7. 非目標・名乗らないこと

- 本番習慣アプリ／ヘルスケア製品の置き換え
- 実在ユーザー習慣ログの収集・公開
- Watch アプリ、ソーシャルランキング
- 福利厚生ポータル化
- モバイルをクラスタに載せて「本番配信」と名乗ること

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| mobile `npm test` | domain（streak/calendar/date/stats）+ auth-headers |
| api `npm test` | 隔離・local_date・CORS・seed |
| CI mobile | unit、npm audit allowlist、Trivy |
| CI api | unit、npm audit、Trivy、kustomize、compose config |
| モバイル E2E／実機通知 | ローカル。CI 本線外 |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | `docs/01-requirements.md` / `05-api.md` が「通知未実装・モバイルは API を呼ばない」 | **コードは通知＋同期済**。文書大幅遅れ |
| 2 | requirements「API も K8s に載せない」vs api `deploy/k8s` | DESIGN/AGENTS はモバイル非載せ。API は overlay 可 |
| 3 | 習慣更新／アーカイブ HTTP なし | 作成＋ログ中心 |
| 4 | 競合マージは LWW 専用エンドポイントなし | push/pull の素朴 upsert |
| 5 | OpenAPI 未 | DESIGN 共有は「OpenAPI だけ」想定だが手書きクライアント |
| 6 | カタログ後続・staging プロファイル | backlog |

---

## 10. 根拠パス

- メタ: `portfolio-plan/habit-tracker/DESIGN.md`、`docs/*`、`habit-tracker/AGENTS.md`、`portfolio-idea/22-*.md`
- 製品: `pf-habit-mobile/README.md`、`src/domain`、`src/sync`、`src/notifications`；`pf-habit-api/README.md`、`src/app.ts`、`deploy/`
