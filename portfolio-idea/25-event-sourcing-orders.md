# イベントソーシング注文処理

注文の状態を「最新行の上書き」ではなく、イベントの列として保存し、投影（リードモデル）を作ります。バックエンドの設計力、一貫性、再構築可能性をアピールできます。DDD に興味がある企業向けです。

## 概要

注文作成、支払い成功/失敗、出荷、キャンセルをイベントで表現します。コマンド API がイベントを append し、ワーカーが「注文一覧」「顧客の注文履歴」などのビューを更新します。CQRS を小さな範囲で適用します。

## 就職活動でのアピールポイント

- イベントとコマンドの違い
- 楽観的並行性（stream version）
- 冪等な投影
- リプレイでリードモデル再構築
- Outbox または同一 DB のイベントテーブル

## 解決する課題

「この注文はなぜキャンセルされたか」を履歴として残し、監査とデバッグを容易にします。在庫や課金の失敗を補償する話にもつなげられます（05 番の理論編）。

## 想定ユーザー

小さな EC の注文サブシステム。UI は管理画面が中心で十分です。

## 主要機能

### 必須（MVP）

- コマンド: CreateOrder, PayOrder, CancelOrder, ShipOrder
- 不正な遷移は拒否（paid 後の pay など）
- イベントストア閲覧（管理用）
- リードモデル: 注文一覧（status, amounts）
- リプレイ API（開発用、投影テーブルを作り直す）

### 推奨

- スナップショット（N イベントごと）
- プロセスマネージャ（支払いが 30 分なければ自動キャンセル）
- 通知投影（メール送信済みフラグ）
- OpenAPI とイベントカタログ（Avro/JSON Schema）
- タイムライン UI（イベントを人間向けに表示）

### 発展

- Kafka は必須ではない。Postgres の `events` テーブルで十分学習できる
- 複数集約横断は Saga として小さく

## 画面構成

| 画面 | 役割 |
| --- | --- |
| 注文一覧 | リードモデル |
| 注文タイムライン | イベント列 |
| 管理 | リプレイ、投影ラグ |

## API 概要

- `POST /orders/commands/create`
- `POST /orders/:id/commands/pay`
- `GET /orders`（query 側）
- `GET /orders/:id/events`
- `POST /admin/projections/rebuild`

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| 言語 | TypeScript / Go / Java / C#（イベントソーシングの例が多い言語） |
| DB | PostgreSQL（events + projections）。`jsonb` |
| ワーカー | LISTEN/NOTIFY またはポーリング |
| フロント | シンプルな管理 UI |
| テスト | コマンド→イベントの仕様テスト（Given events / When command / Then events） |

## アーキテクチャ

Command handler が stream を load（または snapshot + 差分）→ ビジネスルール → append events（version 一致）→ 投影が catch-up。Query API は投影だけ読む。

## データモデル（概要）

- `event_streams`（aggregate_id, version）
- `events`（stream_id, version, type, payload, occurred_at）
- `order_list_view`
- `processed_events`（投影のチェックポイント）

## セキュリティ・品質

- 管理リプレイは認証、本番相当では危険なので開発限定
- ペイロードにカード番号を入れない
- イベントは不変（update/delete しない）。修正は補償イベント

## 実装の進め方

1. 注文集約の純粋な状態遷移テスト
2. イベントストア
3. 投影と一覧 API
4. タイムライン UI
5. リプレイとプロセスマネージャ

## 工数目安

- MVP: 2〜3 週間
- 推奨: 4 週間

## 面接での話し方

「全部をイベントソーシングにしなくてよい。監査と複雑なライフサイクルがある注文だけにした」が良い答えです。投影ラグ（数秒）をどう UI に出すかも話題になります。

## 公開時のチェックリスト

- イベント一覧の意味を表にする
- 不正遷移のテスト一覧
- リプレイ手順
