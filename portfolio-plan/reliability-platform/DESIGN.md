# P12 reliability-platform — 設計方針

## この資料の使い方

実装チャットでは次を渡す。

- `portfolio-plan/00-overview.md`
- 本ファイル
- `portfolio-idea/04-incident-management.md`
- `portfolio-idea/30-sre-runbook-simulator.md`

観測連携時は `cloud-platform/DESIGN.md`。シナリオの題材に P06 を使う場合は `commerce-platform/DESIGN.md`（読み取り・仮想化のみ）。

## 対応アイデア

- 04 障害インシデント管理
- 30 SRE ランブック + 障害対応シミュレーター

## 目的

「今起きている障害」と「どう判断するかの練習」を 1 製品にする。インシデント画面から該当ランブックへ、訓練クリア後に同じランブックへ、と相互リンクする。観測（P02）や EC（P06）を **壊しにいく自動修復は実装しない。**

## リポジトリ構成（モノレポ）

同一 UX、同一サービスカタログ、同一ユーザー。訓練エンジンとインシデント API をポリレポにするとサービス名マスタが二重になる。

```
pf-reliability/
  apps/web
  apps/api           # インシデント、オンコール、ランブック、訓練セッション
  packages/scenario  # YAML シナリオの純関数遷移。破壊的 I/O なし
  packages/openapi
  deploy/
```

Webhook 受信と UI は同じ API でよい。負荷が分かれたら `apps/ingest` をモノレポ内パッケージとして分ける。

## 技術スタック

| 層 | 採用 |
| --- | --- |
| Web | Next.js。訓練画面は観測パネル + 手順の左右分割 |
| API | Go または NestJS |
| DB | PostgreSQL |
| ジョブ | エスカレーションの遅延キュー（Redis） |
| 通知 | メール / Slack webhook。訓練モードでは送らないフラグ |
| 認証 | P01 |

## 設計思想

- **アラートとインシデントは別。** 同一 `dedup_key` は集約
- **状態機械を明示。** triggered → acknowledged → resolved
- **訓練は仮想メトリクス。** シナリオ YAML 以外の世界を変えない
- **ランブックに任意コマンド実行を埋め込まない**
- **Webhook は署名と冪等**

## 2 アイデアの結合

| 機能 | 実体 |
| --- | --- |
| サービス | 共通マスタ（例: Checkout API） |
| 本番インシデント | アイデア 04。Webhook または手動起票 |
| ランブック | Markdown + チェックリスト。サービスに紐づく |
| 訓練 | アイデア 30。仮想状態。完了時に「練習インシデント」を resolved で残して履歴にしてもよい |

P06 の在庫停止を題材にする場合、シナリオは **合成した時系列** を出す。訓練 UI のボタンから本番 `kubectl` は呼ばない。

## 実装順序

1. サービスマスタ、インシデント CRUD、Ack/Resolve、タイムライン
2. Webhook + HMAC + dedup
3. オンコール週次ローテーションと通知（開発はログ出力でも可）
4. ランブック CRUD
5. シナリオエンジン + 1 本目（不良デプロイのロールバック判断）
6. 採点、履歴、シナリオを 3 本
7. 任意: P02 アラートを webhook で受信（本番操作なし）

## 実装上の注意点

- 統合キーをマスク、ローテーション可
- 訓練セッションのアクションは許可リスト（observe, rollback, scale, escalate, declare_resolved）
- scale は仮想効果だけ。改善しないシナリオを 1 本入れ、誤った操作を学べるようにする
- SEV とページング要否を設定化
- 公開デモで他人をページングしない

## 他プロジェクトとの契約

P02 のアラート JSON（例）:

```json
{
  "dedup_key": "commerce-inventory-5xx",
  "severity": "SEV2",
  "service": "inventory",
  "summary": "5xx ratio > 5%"
}
```

P06 とは文書上の依存（シナリオの物語）に留め、ネットワーク結合は任意。

## デモ

- curl で同じイベントを 2 回送りインシデント 1 件
- 訓練で誤って scale しても直らず、rollback で成功
- 「本番システムは操作しない」を画面に出す

## 非目標

- 自動 rollback ボット
- 実クラスタへの診断コマンド実行
- PagerDuty の完全互換
