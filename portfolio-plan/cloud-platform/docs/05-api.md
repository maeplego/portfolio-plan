# P02 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | demo-api と全 `pf-*` が守る health / OTLP。K8s Ingress はランブック |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 基準 | demo-api `http://localhost:8080`（o11y Compose） |

OpenAPI ファイルは無い。本ファイルが人間向け契約。製品 API のパスは各 Pxx の `05-api.md`。

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

## 4. 計画

P12 へ送るアラート JSON（DESIGN の例）は **未配線**。P12 の受信 API は P12 の `05-api.md`。
