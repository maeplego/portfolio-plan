# P05 calendar — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-calendar`（slot-engine / api / web / worker / deploy） |
| 設計 | [calendar/DESIGN.md](../calendar/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P05** |
| 元アイデア | 11 予約・日程調整 |
| 役割 | 空きルール→スロット→ダブルブッキングなし予約（Calendly ミニ）。P10 面接の裏側 |
| 構成 | Hono API（:8095）、Next web（:3005）、worker、Mailhog（:8025）、Postgres |

---

## 2. 目的・スコープ

ホスト現地 TZ と矛盾しない公開スロット。予約確定の正は API のみ。

**含む:** Temporal slot-engine、イベントタイプ／ルール／例外、公開 slots+book（冪等）、キャンセル、ICS、ホスト UI、リマインド worker、outbox→`calendar.booking.confirmed`、内部 API（P10）、OpenAPI、Postgres gist exclusion。

---

## 3. 実装済み機能

### 3.1 公開 API

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/public/:slug/slots` | 最大 14 日 |
| POST | `/public/:slug/book` | 冪等。cancelToken は新規のみ |
| POST | `/public/bookings/cancel` | トークン取消 |
| GET | `/public/bookings/ics` | ICS |
| GET | `/health` `/ready` `/openapi.yaml` | |

### 3.2 ホスト `/v1`／内部 `/internal/v1`

ホスト: event-types／rules／overrides／bookings。内部: `CALENDAR_INTERNAL_TOKEN` で event-types 冪等作成・booking 照会（P10）。

### 3.3 Web／Worker

`/book/[slug]`、`/cancel`、`/host*`。リマインド（Mailhog）、webhook 配信。

### 3.4 無いもの

ラウンドロビン、決済予約、勤怠打刻、Google Calendar 同期（未実装）。

---

## 4. 認証・テナント・環境変数

ゲスト予約は非ログイン。ホストは `CALENDAR_DEV_AUTH` + `X-Dev-Host-Sub` または OIDC。org モデルなし（ホスト=`sub`）。

**主要 env:** `CALENDAR_DATABASE_URL`、`CALENDAR_WEBHOOK_URL`（Compose 既定 talent `:8091`）、`CALENDAR_INTERNAL_TOKEN`。

---

## 5. デモ起動

```powershell
copy deploy\.env.example deploy\.env
docker compose -f deploy/compose.yaml --env-file deploy/.env up --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3005 | Web |
| http://localhost:8095/health | API |
| http://localhost:8025 | Mailhog |

**レビューパックに p05 無し。** 単体 Compose または K8s overlay C。

---

## 6. 他 Pxx との契約

- **P01:** ホストログイン。ゲストは不要。
- **P10:** 企業 `sub`＝ホスト、`calendar.booking.confirmed`。talent-api は webhook 受信実装済み（docs「未実装」は遅れ）。
- **P09:** 統合しない。

---

## 7. 非目標

Calendly 置き換え、複雑なラウンドロビン、決済予約、勤怠。

---

## 8. テスト

`npm test`（slot-engine／api／worker）、Postgres exclusion（Compose 無なら skip）、Playwright（CI 外）、`compose-smoke.mjs`。

---

## 9. ギャップ／注意点

| # | 内容 |
| --- | --- |
| 1 | ~~docs の「P10 webhook 未実装」~~ → 追随済 |
| 2 | review pack に p05 なし → **意図どおり**（Compose / overlay C） |
| 3 | ~~Compose 既定 `CALENDAR_INTERNAL_TOKEN` 空~~ → `.env.example` にデモ値 |
| 4 | Google 同期は未実装 |

---

## 10. 根拠パス

- `portfolio-plan/calendar/DESIGN.md`、`docs/05-api.md`、`calendar/AGENTS.md`
- `pf-calendar/apps/api`、`packages/openapi`、`deploy/compose.yaml`
- `pf-talent-api` `/webhooks/calendar`、overlay `c-scheduling-talent`
