# ポートフォリオ（設計と手順）

就職活動用の学習ポートフォリオです。30 のアイデアを 15 プロダクト（＋給与デモ P16）にまとめ、認証・メディア・観測などを共有しています。**本番システムの置き換えではありません。**

このリポジトリにはアイデア、設計、採用向けの入口があります。動くコードは別リポジトリ（`pf-*`）です。

## まず読むもの（読者別）

| あなた | 開く順 |
| --- | --- |
| **採用担当・レビュア** | 1. [portfolio-plan/HIRING.md](portfolio-plan/HIRING.md) → 2. [REVIEW.md](portfolio-plan/REVIEW.md)（動かしたいとき） |
| 実装・エージェント | [AGENTS.md](./AGENTS.md) → [portfolio-plan/instructions.md](portfolio-plan/instructions.md) |
| 英語のみ | [portfolio-plan/HIRING.en.md](portfolio-plan/HIRING.en.md) |
| 自分の面接準備 | [portfolio-plan/interview-talking-points.md](portfolio-plan/interview-talking-points.md)（採用担当向けではない） |

公開アカウントは [maeplego](https://github.com/maeplego) です。プロフィールのピンは 3 本（このリポジトリ、画面のある本線 1 本、深さ 1 本）。

## プロダクト一覧

| 番号 | リポジトリ | 概要 |
| --- | --- | --- |
| P01 | [pf-identity](https://github.com/maeplego/pf-identity) | OpenID Connect の Identity Provider |
| P02 | [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y) / [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) / [pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws) | 観測、Kubernetes 連携、Terraform モジュール（AWS へは apply しない） |
| P03 | [pf-media](https://github.com/maeplego/pf-media) | ファイル保存と画像派生 |
| P04 | [pf-workspace](https://github.com/maeplego/pf-workspace) | カンバン、Wiki、チャット、共同編集 |
| P05 | [pf-calendar](https://github.com/maeplego/pf-calendar) | 公開予約とスロット計算 |
| P06 | [pf-commerce](https://github.com/maeplego/pf-commerce) | EC（在庫引当、注文、ストアフロント） |
| P07 | [pf-recommend](https://github.com/maeplego/pf-recommend) | 推薦の学習と推論 |
| P08 | [pf-content-blog](https://github.com/maeplego/pf-content-blog) / [pf-content-shortener](https://github.com/maeplego/pf-content-shortener) / [pf-content-infra](https://github.com/maeplego/pf-content-infra) | 技術ブログと URL 短縮 |
| P09 | [pf-attendance](https://github.com/maeplego/pf-attendance) | 勤怠の打刻と月次カレンダー |
| P10 | [pf-talent-api](https://github.com/maeplego/pf-talent-api) / [pf-talent-web](https://github.com/maeplego/pf-talent-web) | 求人マッチング |
| P11 | [pf-developer-scanner](https://github.com/maeplego/pf-developer-scanner) ほか `pf-developer-*` | スキャナ、CLI、OpenAPI ポータル、CI 閲覧、PR レビュー |
| P12 | [pf-reliability](https://github.com/maeplego/pf-reliability) | 仮想インシデントと訓練採点 |
| P13 | [pf-data](https://github.com/maeplego/pf-data) | 架空 CSV の ETL |
| P14 | [pf-finance](https://github.com/maeplego/pf-finance) | 家計簿 PWA（架空データ） |
| P15 | [pf-habit-mobile](https://github.com/maeplego/pf-habit-mobile) / [pf-habit-api](https://github.com/maeplego/pf-habit-api) | 習慣トラッカー（アプリは Kubernetes に載せない） |
| P16 | [pf-payroll](https://github.com/maeplego/pf-payroll) | 給与連携デモ（規制名乗りはしない） |

単体デモは各 `pf-*` の Docker Compose です。まとめ起動は [pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s) の `scripts/review-up.ps1`（手順は REVIEW.md）。

## 全体地図・運用（採用スキムの後で）

| 資料 | 内容 |
| --- | --- |
| [portfolio-plan/00-overview.md](portfolio-plan/00-overview.md) | 15+1 プロダクトの役割と非目標（実装地図） |
| [portfolio-plan/licensing.md](portfolio-plan/licensing.md) | デモ／評価・無保証・商用は別契約 |
| [portfolio-plan/git-branching.md](portfolio-plan/git-branching.md) | ブランチ戦略 |
| [portfolio-plan/cost-estimate.md](portfolio-plan/cost-estimate.md) | 受託再構築の概算見積 |

## ライセンスと利用条件

本リポジトリは **デモ・学習・社内評価用** です。現状品質に **保証はありません**。

- 許可: クローン、ローカル実行、学習、非本番の評価
- 別契約が必要: 本番運用、有償サービスへの組込み、再販・托管の提供

詳細は [LICENSE](./LICENSE) と [portfolio-plan/licensing.md](portfolio-plan/licensing.md) を参照してください。
