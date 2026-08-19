# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | reliability-platform（GitHub: [pf-reliability](https://github.com/maeplego/pf-reliability)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 自動化は `apps/api` の `go test ./...`。この表と食い違ったらテストかこの文書を直す |

## 方針

ドメイン（状態機械・HMAC・dedup）を HTTP より先に固定する。シナリオはクラスタ I/O 無し。実在の障害チケットを fixture にしない。

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-L01 | 状態機械 | triggered から ack / 直接 resolve。resolved への ack は拒否。再送は冪等 |
| TS-L02 | HMAC | 無し・改ざんは 401。正当なら起票または集約 |
| TS-L03 | dedup | 同一キーは未解決 1 件。解決後は新規 |
| TS-L04 | event_id | 同じ署名付き body の再送は同一 incident |
| TS-L05 | シナリオ | scale は不合格、rollback は合格。未知 action は 400 |
| TS-L06 | 認可 | ヘッダ無しの POST は 401。GET 一覧は開ける |
| TS-L07 | ready | DB 不通なら `/ready` 503 |

未自動化: Compose 実機の画面操作、オンコール週次、ランブック CRUD。
