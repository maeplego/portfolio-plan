# P02 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | 実装済みの Compose / overlay A–F / Terraform validate |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

レビュアと各 `pf-*` から見た振る舞い。モジュール分割と state の内部は [03-design.md](03-design.md)。

## 1. 用語

| 用語 | 意味 |
| --- | --- |
| 単体デモ | その製品の Compose だけ。他 Pxx 無しで完結 |
| 連携デモ | Docker Desktop Kubernetes + `pf-cloud-k8s` overlay |
| Collector | OpenTelemetry Collector。アプリの唯一の OTLP 出口 |
| overlay | kustomize の用途別束。A/B/C/D/E/F は実装済み（D は P06 サブセット） |

## 2. 単体デモ（観測）

1. `pf-cloud-o11y` の Compose を上げる
2. demo-api `http://localhost:8080`、Grafana `http://localhost:3000`、Prometheus `http://localhost:9090`
3. `ENABLE_DEBUG=true` のときだけ `/debug/slow` と `/debug/fail` が有効
4. 他アプリは `OTEL_EXPORTER_OTLP_ENDPOINT` を Collector に向ける。未設定なら計装無しで動いてよい

失敗: Compose が落ちたら Grafana は空。アプリは Collector 未到達でもリクエスト自体は 2xx/5xx を返す（テレメトリ欠落はデモ失敗であり、API 契約違反ではない）。

## 3. 連携デモ

手順の正本は `portfolio-plan/integration-demo.md`。

- context は `docker-desktop`。standalone kind のまま apply しない
- overlay は同時に全部載せない。切替は先に down
- Ingress はホスト名（`idp.localhost` 等）。パス prefix は使わない
- URL 表は `pf-cloud-k8s/docs/urls.md`（運用ランブック）

未実装の P07/P11/P12/P13 を overlay D に「完成」と書かない。E は P11 なし。F は P15 Expo なし。

## 4. Terraform（面接用。実行は非目標）

資格情報が無くても:

- `terraform fmt -recursive`
- `init -backend=false` と `validate`（`envs/dev-p09-attendance`）

資格情報があるとき `plan` してよい。**`apply` はこのポートフォリオの完成条件ではない。** 誤って apply した場合の destroy と概算コストは `pf-cloud-aws` README。

リモート state（S3 + DynamoDB lock）はモジュールが想定する完成形である。ラップトップの `terraform.tfstate` を完成扱いにしない。bootstrap はニワトリ卵のためローカル state を例外とする、という説明用の設計であり、実行義務ではない。

## 5. アプリが守る契約

各製品は次を外部から見える。

- `GET /health` — プロセス生存
- `GET /ready` — 依存。MVP では 200 固定でも可
- ログ 1 行 JSON。キー `service`, `trace_id`, `span_id`（span があるとき）
- ルートは `:id` などに正規化した `http.route`

禁止: アプリから Tempo / Jaeger / Loki へ直接送る。Prometheus ラベルに unbounded ID。

## 6. エラーと時刻

- demo-api の障害注入はデバッグビルド限定。本番相当フラグは無い（ローカルのみ）
- 時刻は Collector / Grafana の UTC 表示。アプリは各自の契約

## 7. 画面（計画含む）

Grafana ダッシュボード **Demo API RED** は実装済み。P12 の訓練画面は P12 側。未実装のポータルは計画と書く。
