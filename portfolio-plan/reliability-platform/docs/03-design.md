# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | reliability-platform（GitHub: [pf-reliability](https://github.com/maeplego/pf-reliability)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 構成

```
apps/api        Go。インシデント、webhook、訓練採点
apps/web        Next.js。一覧とタイムライン
packages/scenario  YAML シナリオの純関数。破壊的 I/O なし
packages/openapi
deploy          Compose。Postgres。Kubernetes overlay では RELIABILITY_DATABASE_URL
```

インシデントの正は Postgres。`RELIABILITY_DATABASE_URL` が空のときだけメモリ（単体テスト）。Compose をメモリ店舗のままデモしない。

## 2. アラートとインシデント

受信イベントと画面のインシデントは別物。未解決の `dedup_key` で畳む。解決後は新しい行。Webhook は HMAC と `event_id` 記憶。

## 3. 訓練エンジン

`packages/scenario` は仮想メトリクスと操作の採点だけを返す。scale 失敗・rollback 成功のような規則は純関数テストで固定する。ランブック本文の CRUD と訓練履歴テーブルはまだ無い。

## 4. 認可と秘密

書き込み（起票・ack・resolve・コメント・デモアラート）は `X-Dev-User-Sub`。統合シークレットは一覧でマスク。回転 UI は未実装。

## 5. 他製品

[pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) の Alertmanager 送信は未配線。[pf-commerce](https://github.com/maeplego/pf-commerce) はシナリオの物語上の依存のみ。
