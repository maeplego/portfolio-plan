# P02 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | 受け入れはローカル観測と連携 overlay。AWS `apply` は合格条件に含めない |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

## 1. 背景と目的

各製品リポジトリに VPC や Grafana をコピーすると、計装キーと破棄手順がすぐドリフトする。「アプリの箱」と「見る手段」を標準化する。学習用であり、本番クラウド運用の置き換えではない。

ローカルデモは 2 モードだけを必須にする。AWS 3-tier は面接で構成を話すための Terraform モジュールであり、このポートフォリオは **本番として AWS に載せない。**

## 2. スコープ

### 含む（現状スライスで満たす）

- Compose で Collector / Prometheus / Loki / Tempo / Grafana を起動し、サンプルアプリの RED とトレースを相関できる
- アプリは OTLP を Collector に送り、ベンダー SDK を Grafana / Tempo に直接繋がない
- Docker Desktop Kubernetes 上の用途別 overlay（A foundation、B collab サブセット、C scheduling-talent）
- `GET /health` と `GET /ready`、JSON ログの最低キー
- P09 向け 3-tier モジュール（VPC / ALB / ECS / RDS / GitHub OIDC / 請求アラーム）と `terraform fmt` / `validate`

### 含まない（意図的。「できた」扱いにしない）

| 項目 | 理由 |
| --- | --- |
| AWS への `terraform apply` / 本番相当の常時稼働 | 非目標。課金と秘密の正本を個人アカウントに置かない |
| overlay D/E/F の完成 | 計画。matrix に「未来」と書く |
| overlay B への P11 portal | 計画 |
| サービスメッシュ、マルチリージョン、長期保持の課金最適化 | 非目標 |
| 15 Pxx を 1 クラスタで同時フル起動 | 非目標 |

## 3. アクター

| アクター | 定義 | 認証（現状） |
| --- | --- | --- |
| レビュア | Compose または overlay を起動する人 | なし。Grafana はローカルパスワード |
| 製品アプリ | OTLP と health を守る `pf-*` | 各 Pxx の dev 認証または P01 |
| オペレーター（自分） | overlay 切替、イメージ build | kubectl context `docker-desktop` |
| P12（将来） | アラート webhook を受ける | 計画。今は o11y の debug 注入 |

## 4. 前提・制約

- 単体デモは各 `pf-*/deploy/compose.yaml`。連携デモは Docker Desktop Kubernetes
- standalone kind をレビュア手順の正にしない
- Terraform state の完成形は S3 + lock だが、apply しないならローカル validate で足りる
- NAT 二重、多 AZ RDS を個人課金で再現しない

## 5. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 観測スタックを Compose だけで起動できる | レビュアが AWS 無しで RED を見る |
| FR-02 | サンプルアプリが Collector 経由でメトリクス・ログ・トレースを出す | 直接 Tempo 送信だと P02 の意味が消える |
| FR-03 | 障害注入（高レイテンシ / 5xx）で Grafana 上の症状が変わる | 症状ベースのデモ |
| FR-04 | 連携 overlay は用途別に分け、同時フル起動しない | 12 GB 制約 |
| FR-05 | 製品 manifest 本文は各 `pf-*/deploy/k8s/`、束ねは `pf-cloud-k8s` | ライフサイクル分離 |
| FR-06 | アプリは `/health` と `/ready` を持つ | kubelet とデモ smoke |
| FR-07 | Terraform モジュールは fmt + validate できる | 面接で 3-tier をコードとして示す |
| FR-08 | README に学習用・destroy・概算コストを書く | 誤 apply と放置課金 |

## 6. 非機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | Grafana をインターネットに素通ししない | 学習用でも認証無し公開はしない |
| NFR-02 | Prometheus / Loki ラベルに user id / order id を入れない | カーディナリティ |
| NFR-03 | Secret を Git の Kubernetes Secret 平文で置かない | overlay は `.env` / patch |
| NFR-04 | SSH `0.0.0.0/0:22` をモジュールに置かない | 踏み台を作らない |
| NFR-05 | 観測スタックの保持は数日 | ディスク |

## 7. 受け入れ

次を示せたら、この要件定義の対象範囲は満たす。AWS 上で ALB が応答することは含めない。

1. `pf-cloud-o11y` Compose で Grafana が開き、demo-api の `/work` がトレースにつながる
2. debug slow / fail で p95 または 5xx がダッシュボードに出る
3. Docker Desktop Kubernetes で foundation または scheduling-talent overlay の smoke が通る（手順は `integration-demo.md`）
4. `terraform -chdir=envs/dev-p09-attendance init -backend=false` のあと `validate` が成功する
5. README に「本番 apply しない」「destroy / コスト」がある
