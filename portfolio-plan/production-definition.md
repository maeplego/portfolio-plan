# 本番の定義（Production definition）

| 項目 | 値 |
| --- | --- |
| 対象 | パッケージ販売・顧客 PoC／本番判断 |
| 第一弾 | Collab（P01 同梱または BYO IdP + P04 ± P03） |
| 最終更新 | 2026-08-21 |

公開リポジトリの現状は **デモ／学習／社内評価**（[licensing.md](./licensing.md)）。本書は「いつ本番と呼んでよいか」のゲート正本である。未充足のまま「本番対応」「商用フル」と書かない。

## 一文定義

**本番**とは、承認済み認証アダプタ（同梱 P01 または BYO OIDC）・テナント隔離・バックアップ／リストア手順・監査ログ・staging での境界テスト／最小 E2E が揃い、実業務データを扱ってもよいと Go 判定した環境である。デモ Compose や dev-auth 付き起動は本番ではない。

## 環境区分

| 環境 | 用途 | 典型 |
| --- | --- | --- |
| local / demo | 学習・採用レビュー・評価ライセンス | 各 `pf-*/deploy/compose.yaml`、dev-auth 可 |
| staging | 商用ゲート検証・顧客 PoC（架空または同意済みデータ） | overlay B（collab）または固定 Compose セット。dev-auth **オフ** |
| production | 実ユーザ／実業務データ | staging と同等以上のゲートをすべて Yes（または Risk Accept 記録） |

## 必須ゲート（Collab）

### 認証

- [ ] production / staging で **dev-auth・開発バイパスが起動拒否**（同梱 P01）
- [ ] 認証は **承認済み Auth アダプタ**のみ（同梱 P01 または [portability.md](./portability.md) の BYO OIDC）
- [ ] 必須クレーム: `sub`、テナント用 `org_id`（またはマッピング設定済みの同等クレーム）

### テナント隔離

- [ ] OIDC 利用時 `org_id` 必須
- [ ] 同一 sub・別 org でデータ非表示または 403（契約テスト緑）
- [ ] 招待・共有リンクの公開範囲が文書化されている

### データ保護

- [ ] 秘密は環境変数／秘密管理のみ（Git に鍵を置かない）
- [ ] バックアップ／リストア手順があり、staging で一度実演記録がある
- [ ] オブジェクト格納は S3 互換設定で差し替え可能（顧客バケット可）

### 品質

- [ ] Collab 依存リポの unit CI 緑
- [ ] 境界テスト（org 隔離、認可コード再利用拒否など）緑
- [ ] 最小 E2E: ログイン → workspace ホーム → org 切替（同梱 IdP 経路）
- [ ] 依存の High 以上脆弱性は方針付き（修正または文書化した例外）

### 可用性・観測（初期）

- [ ] `/health` `/ready` が主要プロセスで応答
- [ ] OTLP または同等で staging からメトリクス／トレースが取れる
- [ ] アラート最低 1 本（例: IdP または workspace API down）
- [ ] 初期 SLO を文書化（例: 月次稼働目標。数値は運用開始時に確定してよい）

### 監査

- [ ] ログイン成功／失敗、トークン発行、org 切替、招待、権限変更など必須イベントが一覧化され出る
- [ ] 保持期間方針がある

### 名乗らない領域（明示）

次は **本番ゲート対象外**（別パッケージ／第 N 弾／外部 SaaS）。満たしていないことを顧客に隠さない。

- 給与計算・源泉／年末調整・法人会計フル ERP（→ 商用第 N 弾。当面は連携）
- 労基準拠を名乗った勤怠
- PCI 準拠の本格決済
- SAML のみの SSO（Enterprise 別。当面は OIDC）

## Go / No-Go

| 判定 | 条件 |
| --- | --- |
| **Go** | 上の Collab 必須ゲートがすべて Yes、または未充足項目ごとに Risk Accept（誰が・いつ見直すか）を記録 |
| **No-Go** | dev-auth が本番相当に残る、org 隔離テストが無い／落ちる、バックアップ未実演、ライセンスが評価のまま実課金運用 |

記録テンプレ: 日付、環境、チェック担当、Yes/No/Risk Accept、残課題。`commercial-roadmap.md` のマイルストーンと対応づける。

## 関連

- [verification.md](./verification.md) — 動作確認の層（L0〜L4）
- [package-catalog.md](./package-catalog.md)
- [portability.md](./portability.md)
- [commercial-roadmap.md](./commercial-roadmap.md)
- [licensing.md](./licensing.md)
- [cost-estimate.md](./cost-estimate.md)
