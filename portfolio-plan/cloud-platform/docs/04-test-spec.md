# P02 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P02 cloud-platform |
| 対象スライス | o11y 単体テスト、k8s smoke スクリプト、Terraform validate |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリのテストとスクリプト。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| demo-api | Go test | health、work、debug ゲート |
| Terraform | `fmt` / `validate`（backend=false） | モジュールが構文として閉じている |
| overlay | `kubectl kustomize` / dry-run スクリプト | 参照切れ |
| 実機 smoke | Docker Desktop 必須。CI 既定では動かさない | 横断 |

exploit / PoC は書かない。障害注入はローカル debug フラグだけ。

## 2. 観測

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-O01 | `/health` `/ready` | 200 |
| TS-O02 | `/work` | 200。トレースが Collector に届くのは手動 Grafana |
| TS-O03 | debug オフ | `/debug/*` が 404 相当 |
| TS-O04 | debug オン slow | レイテンシ上昇（手動 RED） |
| TS-O05 | debug オン fail | 5xx（手動） |

## 3. Kubernetes

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-K01 | context 不一致 | `assert-docker-desktop.ps1` が停止 |
| TS-K02 | foundation smoke | A overlay の Pod Ready（手動・実機） |
| TS-K03 | scheduling-talent smoke | C overlay（手動） |
| TS-K04 | collab smoke | B サブセット（手動）。P11 は無い |
| TS-K05 | e-content smoke | E overlay（手動）。P08 blog + shortener |
| TS-K07 | d-commerce smoke | D overlay（手動）。P06 同時 checkout 201/409。P07 等は無い |

## 4. Terraform

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-T01 | validate | `envs/dev-p09-attendance` が backend=false で成功 |
| TS-T02 | fmt | 差分なし（開発者） |
| TS-T03 | apply | **自動化しない。合格条件にしない** |

## 5. 未自動化（計画と書かないが手動）

Grafana 相関、Ingress `*.localhost`、OIDC ログイン〜 media アップロードは `integration-demo.md` の手動手順。
