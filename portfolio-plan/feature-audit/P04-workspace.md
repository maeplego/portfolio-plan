# P04 workspace — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-workspace`（`apps/api` + `collab` + `web` + `deploy/`） |
| 設計 | [workspace/DESIGN.md](../workspace/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P04** |
| 元アイデア | 01 カンバン、02 Wiki、12 チャット、26 共同編集 |
| 役割 | 小さな開発チームの **作業場所**（Linear + Notion + Slack の極小版） |
| 構成 | Go API（:8096）、Node collab/Yjs（:8097）、Next web（:3006）、Postgres |

チャット WS と Yjs は別経路。collab が落ちてもボード／チャットは動く設計。

---

## 2. 目的・スコープ

**目的:** 1 ワークスペース・1 権限モデルの上にボード／Wiki／チャット／共同編集を載せる。

**含む（DESIGN Phase 1–5 完了扱い）:** WS CRUD、招待参加、OIDC+org+RLS、カンバン（楽観ロック・列カスタム）、Wiki+履歴、Yjs collab、チャット（seq・未読）、横断検索、メンション、添付（P03 任意／ローカル）、スプリントバーンダウン。

---

## 3. 実装済み機能

### 3.1 API（`:8096`）

| 領域 | 主なパス |
| --- | --- |
| ヘルス | `GET /health`, `/ready` |
| WS | `POST/GET /v1/workspaces`, `GET .../:id` |
| メンバー | `GET/PATCH/DELETE .../members*`、招待 accept／leave |
| 招待 | `POST/GET/PATCH .../invitations*`、`GET/POST /v1/invitations/:token(/accept)` |
| ボード | boards／columns／cards（version 楽観ロック）、スプリント／burndown |
| Wiki／Docs | pages 履歴／diff／restore、documents trash |
| collab | `POST /v1/collab-tickets`；内部 authorize／plaintext／snapshot |
| チャット | channels、messages、read、`GET /chat/ws`、chat-tickets |
| 検索・添付 | `GET .../search`、uploads／attachments |

### 3.2 Web（`:3006`）／Collab（`:8097`）

ホーム（OrgSwitcher・招待）、`/join/[token]`、ボード／Wiki／Docs／チャット／検索／メンバー。Yjs WS。

### 3.3 無いもの

OpenAPI、音声／ビデオ、E2EE、GitHub 双方向同期、メッセージ DELETE、P05 面談枠連携。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 開発 | `WORKSPACE_DEV_AUTH` + `X-Dev-User-Sub`。Web は `/?user=` |
| 本番相当 | Bearer OIDC。`OIDC_*` |
| collab | `WORKSPACE_INTERNAL_TOKEN` |

**テナント:** IdP `org_id` → workspaces。Postgres RLS。ロール owner/member/guest。BYO: `deploy/byo-oidc/`。

---

## 5. デモ起動

```powershell
cd deploy
copy .env.example .env
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3006 | Web |
| http://localhost:8096/health | API |

レビューパック: `review-up.ps1 -Pack p04`。K8s overlay B（`workspace.localhost`）。

---

## 6. 他 Pxx との契約

- **P01:** OIDC。`sub`＝メンバー。`org` scope。
- **P03:** 添付 `purpose=wiki|chat`（任意）。
- **P11:** overlay B に portal。scanner/CI 非搭載。
- **P05:** 将来の面談枠は MVP 外。

---

## 7. 非目標

Linear/Notion/Slack 置き換え、音声・ビデオ、E2EE、本番 SLA。

---

## 8. テスト

`apps/api` `go test ./...`、collab／web `npm test`、web build。書類 `workspace/docs/`（OpenAPI なし）。

---

## 9. ギャップ／注意点

| # | 内容 |
| --- | --- |
| 1 | README デモが「メンバー直追加」寄り。招待が本線（docs ドリフト） |
| 2 | 招待 URL フォールバックが `localhost:3005`（カレンダーポート）の可能性 — 要確認 |
| 3 | 単体 Compose＝dev-auth。OIDC は pack p04／BYO |
| 4 | OpenAPI 未作成 |

---

## 10. 根拠パス

- `portfolio-plan/workspace/DESIGN.md`、`docs/*`、`workspace/AGENTS.md`
- `pf-workspace/apps/api/internal/web/server.go`、`apps/web`、`deploy/compose.yaml`
- `pf-cloud-k8s` pack `p04`、overlay B
