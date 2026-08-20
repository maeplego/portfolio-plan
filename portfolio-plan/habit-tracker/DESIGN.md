# P15 habit-tracker — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/22-mobile-habit-tracker.md`

認証結合時は `identity-platform/DESIGN.md`。P14 とは統合しない。

## 対応アイデア

- 22 モバイル習慣トラッカー

## 目的

ネイティブ寄りのモバイル実装（通知、ローカル DB、ストリーク、日付境界）を見せる。Web ばかりのポートフォリオとの差別化。バックエンドは同期のためだけに薄く持つ。

## リポジトリ構成（ポリレポ）

モバイルアプリと API は CI、リリース、署名、審査が全く違う。同じリポジトリだと EAS のキャッシュと API の Docker が干渉しやすい。

| リポジトリ | 役割 |
| --- | --- |
| `pf-habit-mobile` | Expo (React Native)、SQLite、ローカル通知 |
| `pf-habit-api` | 同期 API。Hono または NestJS、PostgreSQL |

共有するのは OpenAPI だけ。モバイルは openapi-generator または手書きクライアント。モノレポにしたい場合でも、後からでも分けられるよう `apps/mobile` と `apps/api` の境界は守る。本方針は最初からポリレポ。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| モバイル | Expo, TypeScript, SQLite（drizzle 等）、expo-notifications |
| 状態 | ストリーク計算は純関数にして単体テスト |
| API | TypeScript, PostgreSQL |
| 認証 | P01 public + PKCE。モバイルのリダイレクト URI を IdP に登録 |
| 同期なし完了 | API なしでも App Store 相当のデモは可。その場合はファイルエクスポートを付ける |

## 設計思想

- **今日のチェックが主操作。** SNS 機能を足さない
- **「今日」はユーザー TZ。** UTC 日付の誤用に注意
- **通知許可の理由を説明する**
- **オフラインファースト。** API ダウンでも記録できる
- **実機デモを成果物にする**

## 実装順序

1. 習慣 CRUD と当日チェック、SQLite
2. ストリークとカレンダーの純関数テスト（TZ、年末）
3. ✅ ローカル通知（expo-notifications。習慣作成時 20:00 リマインド）
4. ✅ 統計画面（直近 30 日の完了率 + ストリーク）
5. ✅ 同期 API（`pf-habit-api`。dev-auth / Bearer OIDC）
6. ✅ モバイル差分同期 + PKCE（`EXPO_PUBLIC_HABIT_OIDC_*` / `pf-habit-mobile` クライアント seed）

## 実装上の注意点

- ストリーク仕様を文章化する（飛ばした日、タイムゾーン変更）
- iOS / Android の対応状況を正直に
- クラウド同期時の他ユーザー隔離テスト
- ストア提出は必須ではない。内部配布手順でよい

## 他プロジェクトとの契約

P01 のみ。P14 とユーザーを共有しても、データストアは分けたまま（IdP の SSO だけ共有）。

## デモ

- 実機またはエミュレータで通知
- オフラインでチェックが残る
- スクリーンショット 4 枚

## 非目標

- Watch アプリ
- ソーシャルランキング
- ヘルスケア連携のやり込み
