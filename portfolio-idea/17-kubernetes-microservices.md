# Kubernetes 上のマイクロサービス基盤

ローカル（kind / k3d / minikube）または安いクラウドで、デプロイ、サービスメッシュなしの素直な K8s リソース、CI からのイメージ更新までを見せます。16 番が「クラウドの箱」なら、本アイデアは「コンテナオーケストレーション」です。

## 概要

フロント、API、ワーカー、PostgreSQL、Redis をマニフェストまたは Helm でデプロイします。HPA、Probe、ConfigMap/Secret、Ingress を実装し、障害注入（pod kill）のデモ手順を残します。

## 就職活動でのアピールポイント

- コンテナ化のベストプラクティス（非 root、マルチステージ、ヘルスチェック）
- K8s の基本リソースを説明できる
- GitOps または CI デプロイ
- リソース制限、HPA
- 可観測性（Prometheus、Grafana、OpenTelemetry）

## 解決する課題

Compose では複数環境の差分管理が弱い。宣言的に「あるべき状態」をリポジトリで管理します。

## 想定ユーザー

自作 API をクラスタで動かす自分。採用担当向けに「ローカル kind で再現可能」が重要です。

## 主要機能

### 必須（MVP）

- Deployment / Service / Ingress（または Gateway）
- liveness / readiness / startupProbe
- Secret（sealed-secrets または外部から注入。平文 Secret を Git に置かない方法を 1 つ）
- ワーカー Deployment（キュー処理）
- PostgreSQL は開発は Helm chart、本番相当は「マネージドを使う」と明記でも可

### 推奨

- HPA（CPU またはカスタムメトリクス）
- PDB、topologySpread（説明できる程度の設定）
- 構造化ログ、Prometheus ServiceMonitor
- kustomize overlays（dev/prod）
- イメージタグを SHA に固定

### 発展

- Argo CD
- Istio は過剰になりがち。NetworkPolicy の方が説明しやすい
- カオス（pod を消しても復旧する動画）

## アプリ側の最小機能

注文や画像サムネイルなど、同期 API + 非同期ジョブがある題材が向きます。05 番の縮小版でも、13 番のサムネイルワーカーでも構いません。

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| クラスタ | kind + Ingress NGINX |
| パッケージ | kustomize（Helm より差分が見やすい場合が多い） |
| CI | GitHub Actions で build & push、kubectl/kustomize はローカル手順でも可 |
| 観測 | kube-prometheus-stack は重いので、必要最小の metrics-server + アプリ /metrics |
| 言語 | アプリは任意 |

## アーキテクチャ

Ingress → frontend → api → postgres。api は redis にジョブを投げ、worker が処理。各 Deployment に resources.requests/limits。

## マニフェストの見せ方

- `deploy/base`, `deploy/overlays/dev`
- README に `kubectl get all` の期待結果
- トラブルシュート集（ImagePullBackOff など自分が踏んだもの）

## セキュリティ・品質

- コンテナ非 root、読み取り専用ルート FS は可能な範囲で
- NetworkPolicy で worker から DB 以外を閉じる、など小さく
- ダッシュボードをクラスタに雑に公開しない
- リソース制限でノート PC が死なないようにする

## 実装の進め方

1. Dockerfile と Compose
2. kind に移植
3. Probe と HPA
4. 観測
5. GitOps または CI

## 工数目安

- MVP: 2〜3 週間（K8s 学習込み）
- 推奨: 4〜5 週間

## 面接での話し方

「なぜ K8s が必要だったか」を先に答えます。個人開発で必須ではないので、「学習とチーム開発を想定した基盤」と位置づけるのが誠実です。liveness と readiness の違いを自分のアプリの例で話します。

## 公開時のチェックリスト

- kind で一発起動するスクリプト
- 構成図（Pod と Service）
- クラウド課金が発生する場合の注意
