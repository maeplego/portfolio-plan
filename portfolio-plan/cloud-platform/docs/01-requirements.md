# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | クラウド基盤（観測 [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y)、Kubernetes [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s)、Terraform [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

各製品リポジトリに VPC や Grafana をコピーすると、計装キーと破棄手順がすぐドリフトする。「アプリの箱」と「見る手段」を標準化する。学習用であり、商用クラウド運用の置き換えではない。

ローカルデモは **単体 Compose** と **Docker Desktop Kubernetes の用途別 overlay** の 2 モード。AWS 3-tier はモジュールと配線が成果物である。このポートフォリオは **AWS へ `terraform apply` しない。**

## 2. 含む

- Compose で Collector / Prometheus / Loki / Tempo / Grafana を起動し、サンプルアプリの RED とトレースを相関できる
- アプリは OTLP を Collector に送る。ベンダー SDK を Grafana / Tempo に直接繋がない
- Docker Desktop Kubernetes 上の用途別 overlay（A foundation、B collab + 開発者ポータル、C scheduling-talent、D commerce、E content、F ops）
- overlay D は EC [pf-commerce](https://github.com/maeplego/pf-commerce) の payment / notify / BFF / ops-web と推薦 [pf-recommend](https://github.com/maeplego/pf-recommend) を含む
- `GET /health` と `GET /ready`、JSON ログの最低キー
- 勤怠 [pf-attendance](https://github.com/maeplego/pf-attendance) 向け 3-tier モジュール（VPC / ALB / ECS / RDS / GitHub OIDC / 請求アラーム）と `terraform fmt` / `validate`

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| AWS への `terraform apply` と本番相当の常時稼働 | 課金と秘密の正本を個人アカウントに置かない |
| overlay D への開発者ポータル / 信頼性 / データ基盤 | いまの D は EC フルと推薦まで |
| overlay E への開発者ポータル | B に portal を載せた |
| サービスメッシュ、マルチリージョン、長期保持の課金最適化 | 範囲外 |
| 15 製品を 1 クラスタで同時フル起動 | メモリ制約。用途別に切る |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| レビュア | Compose または overlay を起動する人 | Grafana はローカルパスワード |
| 製品アプリ | OTLP と health を守る `pf-*` | 各製品の開発認証または認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| オペレーター | overlay 切替、イメージ build | kubectl context `docker-desktop` |
| 信頼性基盤 [pf-reliability](https://github.com/maeplego/pf-reliability) | アラート webhook の受け口（任意） | 観測側の debug 注入が現行のデモ |

## 5. 前提

- 単体デモは各 `pf-*/deploy/compose.yaml`。連携デモは Docker Desktop Kubernetes
- 採用の既定経路は `portfolio-plan/05-review.md` の Compose パック（Kubernetes オフで可）
- standalone kind をレビュア手順の正にしない
- Terraform state の完成形は S3 + lock だが、apply しないためローカル `validate` で足りる
- NAT 二重、多 AZ RDS を個人課金で再現しない

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 観測スタックを Compose だけで起動できる | レビュアが AWS 無しで RED を見る |
| FR-02 | サンプルアプリが Collector 経由でメトリクス・ログ・トレースを出す | 直接 Tempo 送信だと観測基盤の意味が消える |
| FR-03 | 障害注入（高レイテンシ / 5xx）で Grafana 上の症状が変わる | 症状ベースのデモ |
| FR-04 | 連携 overlay は用途別に分け、同時フル起動しない | 12 GB 制約 |
| FR-05 | 製品 manifest 本文は各 `pf-*/deploy/k8s/`、束ねは `pf-cloud-k8s` | ライフサイクル分離 |
| FR-06 | アプリは `/health` と `/ready` を持つ | kubelet とデモ smoke |
| FR-07 | Terraform モジュールは `fmt` と `validate` できる | 3-tier をコードとして示す。apply はしない |
| FR-08 | README に学習用・destroy・概算コストを書く | 誤 apply と放置課金 |
| FR-09 | レビュアが Kubernetes なしで Compose パックを起動できる | overlay を既定にしない |
| FR-10 | overlay D は payment / notify / BFF / ops-web と推薦 API を載せる | Compose と同じプロセス集合 |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | Grafana をインターネットに素通ししない | 学習用でも認証無し公開はしない |
| NFR-02 | Prometheus / Loki ラベルに user id / order id を入れない | カーディナリティ |
| NFR-03 | Secret を Git の Kubernetes Secret 平文で置かない | overlay は `.env` / patch |
| NFR-04 | SSH `0.0.0.0/0:22` をモジュールに置かない | 踏み台を作らない |
| NFR-05 | 観測スタックの保持は数日 | ディスク |

## 8. 受け入れ

1. `pf-cloud-o11y` の Compose で Grafana が開き、demo-api の `/work` がトレースにつながる
2. debug slow / fail で p95 または 5xx がダッシュボードに出る
3. `REVIEW.md` の Compose パックを起動できる。Kubernetes overlay の smoke は任意
4. `terraform -chdir=envs/dev-p09-attendance init -backend=false` のあと `validate` が成功する
5. README に「本番 apply しない」「destroy / コスト」がある
6. AWS 上で ALB が応答することは受け入れに入れない
