# P05 calendar — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/11-booking-scheduler.md`

人間向けの要件・外部仕様・内部設計・テスト仕様・API・図表は `portfolio-plan/calendar/docs/`。書き方は `portfolio-plan/02-documentation.md`。本ファイルは短く保ち、スタックとスライス順の正本にする。

P10 から面接枠を取る実装では `talent-platform/DESIGN.md` も渡す。

## 対応アイデア

- 11 予約・日程調整ツール

## 目的

空きルールからスロットを生成し、ダブルブッキングなく予約する共有サービス。Calendly ミニ。P10 の面接調整、将来の P04 ミーティングの裏側になる。P09 勤怠とは統合しない（労務計算と公開スロットは別境界）。

## リポジトリ構成（モノレポ）

Web（公開ページ + ホスト管理）、API、リマインドワーカーは同一製品で、型と日付計算を共有したい。個人開発でリポジトリを 3 つに割ると TZ テストが複製される。

```
pf-calendar/
  apps/web
  apps/api
  apps/worker
  packages/slot-engine   # スロット計算の純関数。UI からもテストからも使うが、予約確定は API だけが正
  packages/openapi
  deploy/
```

ワーカーだけ別デプロイしても、リポジトリは 1 つ（モノレポ）。インフラが独立してもコードは一緒。

ポリレポにしない理由: スロット計算を web と api にコピーすると TZ バグが二重になる。公開ページと API は同時にリリースする前提。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| Web | Next.js, TypeScript |
| API | Hono。`packages/slot-engine`（`@js-temporal/polyfill`）を import する薄い HTTP 層。Go にはしない（TZ テストが二重になる）。NestJS にもしない（一人開発の予約 API に DI モジュールは過剰） |
| ワーカー | 同じ TypeScript ランタイム。BullMQ または同等 |
| DB | PostgreSQL。可能なら `tstzrange` + exclusion constraint |
| メール | 開発 Mailhog、本番 Resend/SES |
| 認証 | ホストは P01。ゲスト予約は非ログイン（メール + トークン） |

## 設計思想

- **スロットはサーバーが計算する。** クライアントの ISO 文字列を信じない
- **予約確定の正は `apps/api`。** Next.js の Route Handlers / Server Actions に book を置かない。P10 とリマインドワーカーが同じ HTTP 契約を叩く
- **重複は DB が最後の砦。** アプリのチェックだけでは競合する
- **外部カレンダーは副作用。** Google 同期が失敗しても予約は残す
- **ゲスト PII を公開ページに出さない**

## 実装順序

1. `packages/slot-engine` の単体テスト（Asia/Tokyo と America/Los_Angeles、DST、バッファ、min notice）
2. イベントタイプと空きルール、例外日
3. `GET slots` と `POST book` + exclusion
4. 公開 UI とホストダッシュボード
5. キャンセルリンク、ICS
6. リマインドワーカー
7. 内部 API（P10 用）: `createEventTypeForJob` や `listHostAvailability`。これが揃うまで P10 はテキスト希望日時でよい
8. 予約確定イベント `calendar.booking.confirmed`（outbox + worker webhook）
9. `packages/openapi` と `GET /openapi.yaml`
10. Postgres 並列 book の integration テスト（TS-M01）
11. dev 用 webhook 受信スタブ（`POST /webhooks/calendar`）

## 実装上の注意点

- 2 タブ同時予約のテストを CI に入れる
- スロット生成の期間上限（例: 14 日）で CPU を守る
- キャンセルトークンは十分長く、ログに出さない
- ホストの timezone とゲストの timezone を両方保存する
- メール列挙（このメールは登録済み）を予約 API で漏らさない
- Google OAuth トークンは IdP のトークンと混ぜない。カレンダー連携は別 credentials 表

## 他プロジェクトとの契約

P10 向け（後付け）:

- 企業ユーザーの `sub` がホスト
- 求人ごとに event type（面談 30 分）
- 予約確定イベント `calendar.booking.confirmed` を P10 が応募ステータス更新に使う

P01: ホストログイン。ゲストは IdP 不要。

## デモ

- ゲスト TZ を切り替えてもホスト現地の空きと矛盾しない
- 2 タブで同じ枠を取ると 1 件だけ成功

## 非目標

- チームの複雑なラウンドロビン（発展）
- 決済付き予約
- 勤怠の打刻
