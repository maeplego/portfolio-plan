# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | reliability-platform（GitHub: [pf-reliability](https://github.com/maeplego/pf-reliability)） |
| 最終更新 | 2026-08-21 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

「いま起きている障害」と「判断の練習」を同じ製品で扱う。本番クラスタの `kubectl` や自動修復は呼ばない。画面にその旨を出す。

## 1. インシデント状態

`triggered` → `acknowledged` → `resolved`。`triggered` から直接 `resolved` にできる。すでに `resolved` への ack は 409。ack / resolve の再送は冪等（同じ状態のまま 200）。

同一サービス・同一 `dedup_key` で未解決なら 1 件に集約し `alertCount` を増やす。解決後の同一キーは新しいインシデント。

## 2. Webhook

`POST /v1/integrations/{key}/events`。ヘッダ `X-Signature-256: sha256=<hex>` は HMAC-SHA256。署名なし・改ざんは 401。`event_id` で再送を同一件に畳む。統合シークレットは API 応答でマスクする。

## 3. 手動起票とタイムライン

開発ユーザーは `X-Dev-User-Sub` で一覧 GET、手動作成、ack、resolve、コメントができる。[pf-identity](https://github.com/maeplego/pf-identity) は未配線（OIDC は staging 向け設計のみ）。`/health`・`/ready`・仮想メトリクス・訓練採点 POST は認証なし。

`POST /v1/demo/alerts` は擬似 5xx を流して起票のデモにする。観測スタック [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) からの本番アラート配線は未実装。

## 4. 訓練とランブック

`GET /v1/virtual-metrics` はシナリオ用の仮想時系列。`POST /v1/training/score` は操作列 `{ actions }` を採点する。未知操作は 400。クラスタ操作は無い。`GET /v1/training/history` で採点履歴を返す。ランブックは `GET/POST/PUT/DELETE /v1/runbooks`。`GET /v1/oncall` はデモ用の簡易照会。

題材としてコマース障害を物語にすることがあるが、[pf-commerce](https://github.com/maeplego/pf-commerce) の本番 API は呼ばない。
