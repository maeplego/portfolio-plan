# API 仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | クラウド基盤（観測 [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) / Kubernetes [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) / Terraform [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 基準 | demo-api `http://localhost:8080`（o11y Compose） |

OpenAPI ファイルは無い。本ファイルが人間向けの契約要約。製品 API のパスは各製品の `05-api.md`。

## 1. 全アプリ共通

| メソッド | パス | 用途 | 成功 |
| --- | --- | --- | --- |
| GET | `/health` | liveness | 200 |
| GET | `/ready` | readiness。依存が無い MVP は 200 | 200。失敗時 503 |

OTLP: HTTP `:4318` または gRPC `:4317`。環境変数 `OTEL_EXPORTER_OTLP_ENDPOINT`。

## 2. demo-api（`pf-cloud-o11y`）

| メソッド | パス | 条件 | 状態 |
| --- | --- | --- | --- |
| GET | `/health` | 常時 | 200 |
| GET | `/ready` | 常時 | 200 |
| GET | `/work/{id}` | 任意 id | 200。span あり |
| POST | `/debug/slow?ms=` | `ENABLE_DEBUG=true` | 遅延後 200。オフなら拒否 |
| POST | `/debug/fail` | `ENABLE_DEBUG=true` | 5xx。オフなら拒否 |

## 3. Terraform / kubectl

HTTP API ではない。`terraform validate` と `kubectl` smoke は [04-test-spec.md](04-test-spec.md)。

## 4. 未配線

信頼性基盤 [pf-reliability](https://github.com/maeplego/pf-reliability) へ送るアラート JSON（DESIGN の例）は **未配線**。受信 API は信頼性基盤の `05-api.md`。
