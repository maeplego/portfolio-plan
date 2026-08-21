# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | クラウド基盤（観測 [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) / Kubernetes [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) / Terraform [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws)） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | 製品リポジトリのテストとスクリプトを優先する。本表と食い違ったらテストを直すか本表を追随する |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| demo-api | Go test | health、work、debug ゲート |
| Terraform | `fmt` / `validate`（backend=false） | モジュールが構文として閉じている |
| overlay | `kubectl kustomize` / dry-run スクリプト。GHA は `deploy/base` 等と `-ParseOnly` | 参照切れ |
| Playwright / Compose up | 製品リポジトリ。既定 CI ではない（`ci.md`） | 画面とヘルス |
| 実機 smoke | Docker Desktop 必須。CI 既定では動かさない | 横断 |

攻撃手順は書かない。障害注入はローカル debug フラグだけ。

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
| TS-K04 | collab smoke | B overlay（手動）。チーム作業場所 + 開発者ポータル |
| TS-K05 | e-content smoke | E overlay（手動）。ブログ + 短縮 URL |
| TS-K07 | d-commerce smoke | D overlay（手動）。EC 同時 checkout 201/409。推薦 BFF recommended。開発者ポータルと信頼性あり。データ基盤は無い |
| TS-K08 | overlay スコープ | `build-images` の a-foundation は 5、c-scheduling-talent は 7（`test-scripts.ps1`） |
| TS-K09 | スクリプト構文 | `test-scripts.ps1` が *.ps1 を ParseFile |

## 4. Terraform

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-T01 | validate | `envs/dev-p09-attendance` が backend=false で成功 |
| TS-T02 | fmt | 差分なし（開発者） |
| TS-T03 | apply | **自動化しない。合格条件にしない** |

## 5. 未自動化（手動）

Grafana 相関、Ingress `*.localhost`、OIDC ログイン〜 media アップロードは `integration-demo.md` の手動手順。
