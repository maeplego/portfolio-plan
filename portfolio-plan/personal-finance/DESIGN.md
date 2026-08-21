# P14 personal-finance — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/10-household-budget-pwa.md`

認証結合時は `identity-platform/DESIGN.md`。P15 とはドメインを共有しない。

## 対応アイデア

- 10 家計簿 PWA

## 目的

オフライン入力できる家計簿で、フロントの品質（PWA、同期、グラフ、整数金額）を見せる。P15 習慣トラッカーと統合しない。通知中心のネイティブ習慣と、金額の一貫性が中心の家計簿は別製品の方が両方強い。

IdP 以外に依存しないので、フェーズ 2 の並列トラックに向く。

## リポジトリ構成（モノレポ）

PWA と同期 API は同じ同期プロトコル（tombstone, updated_at）を共有する。割るとコンフリクト規則が分岐する。

```
pf-finance/
  apps/web       # Next.js PWA, IndexedDB キュー
  apps/api       # Hono
  packages/money
  packages/sync-protocol  # LWW の純関数
  deploy/
```

起動の正は **Compose**（単独デモ）。`deploy/k8s` の kustomize は CI／ops overlay 用として置いてよい（「K8s 禁止」ではない。単体 apply はしない）。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| Web | Next.js PWA。Workbox 相当の `/sw.js`、IndexedDB キュー、Recharts |
| API | TypeScript（Hono） |
| DB | PostgreSQL |
| 同期 | `packages/sync-protocol` の LWW。行に `updated_at` と `deleted_at` |
| 認証 | P01。public クライアント + PKCE |
| テスト | Playwright で Offline 模擬 |

## 設計思想

- **入力の速さのためローカルが正。** サーバーは同期とバックアップ
- **コンフリクトは LWW + tombstone。** 同時刻はサーバーを残す。クライアントの `updatedAt` がサーバー時計より 120 秒以上未来なら拒否する
- **金額は整数円。** 浮動小数点禁止
- **実家計を入れない。** シードは架空
- **アカウント削除でサーバーデータも消す**

## 実装順序

1. オンライン CRUD と月次グラフ、予算
2. PWA インストール
3. ✅ IndexedDB とオフラインキュー（create/delete。オンライン復帰で POST /sync）
4. ✅ 同期 API（LWW + tombstone。`POST /v1/sync`）
5. ✅ CSV 入出力（整数円。カテゴリは名前突合）
6. ✅ P01（public + PKCE。Compose 既定は `X-Dev-User-Sub`）、ダークモード、削除、ウォレット、繰り返し、tombstone GC、カテゴリ/予算の同期

## 実装上の注意点

- HTTPS 前提。PWA は localhost 例外以外で secure context
- 他ユーザーの取引が取れないテスト
- 繰り返し取引（家賃）は day 1–28 と生成ログ
- E2E 暗号化は発展。やるなら「サーバーが金額を読めない」制限と検索不能を明記

## 他プロジェクトとの契約

P01 のみ。P13 に家計を流さない（個人データ）。

## デモ

- DevTools Offline で入力し、オンライン復帰で残る
- シード 3 ヶ月のグラフ
- アカウント削除

## 非目標

- 銀行 API スクレイピング
- 世帯の複雑な権限（発展）
- 確定申告
