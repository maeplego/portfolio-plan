# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | クラウド基盤（観測 [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) / Kubernetes [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) / Terraform [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

クローンした人が Compose や overlay から見た振る舞い。モジュール分割と state は [03-design.md](03-design.md)。

## 1. 用語

| 用語 | 意味 |
| --- | --- |
| 単体デモ | その製品の Compose だけ。他リポジトリ無しで完結する |
| 連携デモ | Docker Desktop Kubernetes と `pf-cloud-k8s` の overlay |
| Collector | OpenTelemetry Collector。アプリの唯一の OTLP 出口 |
| overlay | kustomize の用途別の束。A〜F は実装済み |

## 2. 単体デモ（観測）

1. [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) の Compose を上げる
2. demo-api `http://localhost:8080`、Grafana `http://localhost:3000`、Prometheus `http://localhost:9090`
3. `ENABLE_DEBUG=true` のときだけ `/debug/slow` と `/debug/fail` が有効
4. 他アプリは `OTEL_EXPORTER_OTLP_ENDPOINT` を Collector に向ける。未設定なら計装無しで動いてよい

Compose が落ちたら Grafana は空になる。アプリは Collector に届かなくてもリクエスト自体は 2xx/5xx を返す（テレメトリ欠落はデモ失敗であり、API 契約違反ではない）。

## 3. 連携デモ

手順は `portfolio-plan/integration-demo.md`。採用担当者の既定は `portfolio-plan/REVIEW.md`（Compose パック）。overlay は任意。

- kubectl context は `docker-desktop`。standalone kind のまま apply しない
- overlay は同時に全部載せない。切替は先に down
- Ingress はホスト名（`idp.localhost` 等）。パス prefix は使わない
- URL 表は `pf-cloud-k8s/docs/urls.md`

現行の overlay:

| overlay | 載せるもの | 載せないもの |
| --- | --- | --- |
| A foundation | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity)、メディア基盤 [pf-media](https://github.com/maeplego/pf-media)、観測 | — |
| B collab | チーム作業場所 [pf-workspace](https://github.com/maeplego/pf-workspace)、上記 + 開発者ポータル [pf-developer-portal](https://github.com/maeplego/pf-developer-portal) | — |
| C scheduling-talent | 予約カレンダー [pf-calendar](https://github.com/maeplego/pf-calendar)、求人 [pf-talent-api](https://github.com/maeplego/pf-talent-api) / [pf-talent-web](https://github.com/maeplego/pf-talent-web) | — |
| D commerce | EC [pf-commerce](https://github.com/maeplego/pf-commerce) フル、推薦 [pf-recommend](https://github.com/maeplego/pf-recommend) | 開発者ポータル、信頼性基盤 [pf-reliability](https://github.com/maeplego/pf-reliability)、データ基盤 [pf-data](https://github.com/maeplego/pf-data) |
| E content | ブログ [pf-content-blog](https://github.com/maeplego/pf-content-blog)、短縮 URL [pf-content-shortener](https://github.com/maeplego/pf-content-shortener) | 開発者ポータル |
| F ops | 勤怠 [pf-attendance](https://github.com/maeplego/pf-attendance)、信頼性、家計 [pf-finance](https://github.com/maeplego/pf-finance)、習慣 API [pf-habit-api](https://github.com/maeplego/pf-habit-api) | Expo アプリ [pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile) |

## 4. Terraform（構文チェックまで。AWS へは適用しない）

資格情報が無くても:

- `terraform fmt -recursive`
- `init -backend=false` と `validate`（`envs/dev-p09-attendance`）

資格情報があるとき `plan` してよい。**`apply` はこのポートフォリオの完成条件ではない。** 誤って apply した場合の destroy と概算コストは `pf-cloud-aws` の README。

リモート state（S3 + DynamoDB lock）はモジュールが想定する完成形である。ラップトップの `terraform.tfstate` を完成扱いにしない。bootstrap はバケット自身を作る例外としてローカル state を使う、という説明用の設計であり、実行義務ではない。

最初の配線先は勤怠 [pf-attendance](https://github.com/maeplego/pf-attendance)。

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

## 7. 画面

Grafana ダッシュボード **Demo API RED** は実装済み。信頼性基盤の訓練画面は [pf-reliability](https://github.com/maeplego/pf-reliability) 側。未実装のポータル画面は計画と書く。
