# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | 信頼性基盤 [pf-reliability](https://github.com/maeplego/pf-reliability) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

「今起きている障害」と「どう判断するかの練習」を 1 製品にする。インシデント画面と訓練は同じサービスマスタを共有する。観測スタック [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) や EC [pf-commerce](https://github.com/maeplego/pf-commerce) を壊しにいく自動修復は実装しない。本番クラスタの `kubectl` は呼ばない。画面にその旨を出す。

学習用であり、PagerDuty の置き換えではない。

## 2. 含む

- サービスマスタ、インシデント CRUD、Ack / Resolve、コメント
- HMAC webhook、`dedup_key` 集約、`event_id` 再送の畳み込み
- 画面文言「本番システムは操作しません」
- 仮想メトリクス GET
- シナリオ純関数の採点（bad-deploy。scale では直らず rollback で回復）
- 擬似アラート `POST /v1/demo/alerts`

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| 自動 rollback ボット、実 kubectl | 訓練は仮想状態だけ |
| PagerDuty 互換、公開ページング | 他人をページングしない |
| オンコール週次ローテーション | 未実装 |
| 訓練セッションの履歴 API、ランブック CRUD | 未実装。採点 API はある |
| 観測からの本番アラート配線 | 任意。いまは debug / demo 注入 |
| 認証基盤の OIDC | 開発ヘッダ。一覧 GET はデモ用に認証なし |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| オンコール担当（開発ユーザー） | 手動起票、ack、resolve、コメント | `X-Dev-User-Sub` |
| 統合（webhook） | アラートを流す | HMAC-SHA256 |
| 訓練者 | 操作列を採点させる | 開発 |

## 5. 前提

- 状態は `triggered` → `acknowledged` → `resolved`。triggered から直接 resolved 可
- 同一サービス・同一 `dedup_key` で未解決なら 1 件に集約
- 解決後の同一キーは新しいインシデント
- 訓練のアクションは許可リスト（observe, rollback, scale, escalate, declare_resolved）
- 題材にコマース障害を使うことがあっても、EC の本番 API は呼ばない

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | インシデントを作成し、ack / resolve / コメントできる | 今の障害 |
| FR-02 | 同じ未解決の `dedup_key` は 1 件に集約し `alertCount` を増やす | アラートとインシデントは別 |
| FR-03 | resolved のあと同一 dedup は新規インシデント | 再発 |
| FR-04 | webhook は HMAC。署名なし・改ざんは 401 | なりすまし |
| FR-05 | 統合シークレットは API 応答でマスクする | 漏洩 |
| FR-06 | 画面に本番システムを操作しない旨を出す | 誤解防止 |
| FR-07 | `GET /v1/virtual-metrics` が訓練用の仮想時系列を返す | 観測パネルの物語 |
| FR-08 | `POST /v1/training/score` が操作列を採点する。scale は減点、rollback で合格。未知操作は 400 | 判断の練習 |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | ランブックに任意コマンド実行を埋め込まない | 破壊的 I/O なし |
| NFR-02 | シナリオパッケージは純関数。クラスタを変えない | 安全 |
| NFR-03 | README に学習用である旨を書く | 誤用 |
| NFR-04 | ack / resolve の再送は冪等 | 二重操作 |

## 8. 受け入れ

1. 同じイベント 2 回でインシデント 1 件
2. 署名無し webhook が 401
3. resolved のあと同一 dedup は新規
4. 画面に本番操作をしない旨がある
5. bad-deploy シナリオで scale が減点、rollback が合格になる
