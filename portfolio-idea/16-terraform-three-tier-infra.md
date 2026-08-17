# Terraform で構築する 3-tier Web 基盤

アプリ本体より「再現可能なインフラ」を主役にしたポートフォリオです。VPC、ALB、オートスケール、RDS、CI からのデプロイまでをコード化し、構成図と apply 手順を残します。インフラ / SRE / クラウド志望に直結します。

## 概要

簡単な Web アプリ（ヘルスチェック、ユーザー CRUD 程度）を、AWS（または GCP）上に Terraform で載せます。環境は `dev` / `prod` を workspace またはディレクトリ分割します。費用爆発を避ける設計が評価対象です。

## 就職活動でのアピールポイント

- IaC、モジュール化、state 管理
- ネットワーク（公開/非公開サブネット、NAT、SG）
- シークレット管理、最小権限 IAM
- ゼロダウンタイムに近いデプロイ（ローリング）
- コストと可用性のトレードオフを言語化できる

## 解決する課題

コンソールポチポチ構築では再現できず、レビューもできません。コードとしてインフラを残します。

## 想定ユーザー

自分のポートフォリオアプリを本番相当の構成で動かす自分自身。採用担当は README の図を見ます。

## 主要機能（インフラ側）

### 必須（MVP）

- VPC、public/private subnet（2 AZ）
- ALB → EC2 ASG または ECS Fargate
- RDS PostgreSQL（private、暗号化）
- アプリの環境変数は SSM Parameter Store / Secrets Manager
- リモート state（S3 + DynamoDB lock）
- タグ規約（Project, Env）

### 推奨

- HTTPS（ACM）、HTTP からリダイレクト
- CloudWatch ログ、アラーム（5xx、CPU）
- GitHub OIDC で AWS ロールを assume（永久キーをリポジトリに置かない）
- バケットの公開禁止、RDS の公開禁止を `terraform plan` で保証
- 構成図（自動生成 mermaid または draw.io をリポジトリに含める）

### 発展

- WAF の最低限
- Blue/Green
- 別リージョンは費用的に非推奨。説明だけでも可

## アプリ側の最小機能

- `GET /health`
- 簡単な掲示板または URL 短縮でも可
- マイグレーションは起動時または CI

インフラが主役なので、アプリは薄くて構いません。

## 技術スタック（推奨）

| 層 | 候補 |
| --- | --- |
| IaC | Terraform >= 1.x、AWS Provider |
| アプリ | 任意（Go の小さな API がイメージも軽い） |
| CI | GitHub Actions + OIDC |
| 図 | terraform-docs、アーキテクチャ PNG |
| 代替 | GCP Cloud Run + Terraform、Azure でも可。求人に合わせる |

## アーキテクチャ

Internet → ALB（public）→ アプリ（private）→ RDS（private）。NAT は費用がかかるので、Fargate + VPC endpoints や、学習用は NAT 1 つ、と選択理由を書きます。

## ディレクトリ構成例

- `infra/modules/network`
- `infra/modules/app`
- `infra/modules/data`
- `infra/envs/dev`
- `app/`

## セキュリティ・品質

- シークレットを Git に置かない
- SG は 0.0.0.0/0:22 を開けない（SSM Session Manager）
- `terraform fmt`, `validate`, `tflint`, checkov または tfsec を CI に入れる
- 破棄手順（`destroy`）と月額見積を README に書く

## 実装の進め方

1. ローカル Docker でアプリ
2. 単一 EC2 手動相当を Terraform 化
3. 3-tier に拡張
4. CI OIDC
5. 監視アラーム

## 工数目安

- MVP: 2 週間（クラウド課金に注意）
- 推奨: 3〜4 週間

## 面接での話し方

「NAT を 2 つにしなかった理由（コスト）」「state をなぜリモートにしたか」「OIDC にした理由」が定番です。無料枠とアラーム（請求）を設定した話は実務的で好印象です。

## 公開時のチェックリスト

- 月額の見積（数百円〜数千円）と destroy 手順
- plan のサンプル出力（秘密はマスク）
- 構成図
- 絶対に AWS キーをコミットしない
