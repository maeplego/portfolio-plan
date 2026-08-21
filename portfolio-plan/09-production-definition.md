# 本番の定義（Production definition）

> **読者**: 商用準備・運用向け。採用スキムは [03-hiring.md](./03-hiring.md) → [05-review.md](./05-review.md)。

| 項目 | 値 |
| --- | --- |
| 対象 | パッケージ販売・顧客 PoC／本番判断 |
| 第一弾 | Collab（P01 同梱または BYO IdP + P04 ± P03） |
| 最終更新 | 2026-08-21 |

公開リポジトリの現状は **デモ／学習／社内評価**（[15-licensing.md](./15-licensing.md)）。本書は「いつ本番と呼んでよいか」のゲート正本である。未充足のまま「本番対応」「商用フル」と書かない。

## 一文定義

**本番**とは、承認済み認証アダプタ（同梱 P01 または BYO OIDC）・テナント隔離・バックアップ／リストア手順・監査ログ・staging での境界テスト／最小 E2E が揃い、実業務データを扱ってもよいと Go 判定した環境である。デモ Compose や dev-auth 付き起動は本番ではない。

## 環境区分

| 環境 | 用途 | 典型 |
| --- | --- | --- |
| local / demo | 学習・採用レビュー・評価ライセンス | 各 `pf-*/deploy/compose.yaml`、dev-auth 可 |
| staging | 商用ゲート検証・顧客 PoC（架空または同意済みデータ） | overlay B（collab）または固定 Compose セット。dev-auth **オフ** |
| production | 実ユーザ／実業務データ | staging と同等以上のゲートをすべて Yes（または Risk Accept 記録） |

## 必須ゲート（Collab）

凡例: **Yes** / **No** / **Risk Accept**（誰・見直し日を記録）。自己監査日: 2026-08-21。

### 認証

- [x] **Yes** — production / staging で **dev-auth・開発バイパスが起動拒否**（同梱 P01: `IDENTITY_ENV`、P04: `WORKSPACE_ENV`）
- [x] **Yes** — 認証は **承認済み Auth アダプタ**のみ（同梱 P01 または [12-portability.md](./12-portability.md) の BYO OIDC。Entra/Auth0 実テナントは顧客環境で確認）
- [x] **Yes** — 必須クレーム: `sub`、テナント用 `org_id`（または `OIDC_ORG_CLAIM` / `OIDC_ORGS_CLAIM` マッピング）

### テナント隔離

- [x] **Yes** — OIDC 利用時 `org_id` 必須（staging/production プロファイル）
- [x] **Yes** — 同一 sub・別 org でデータ非表示または 403（契約テスト＋ memory tenant filter）
- [x] **Yes** — 招待・共有リンクの公開範囲が文書化されている（[workspace/docs/10-invite-visibility.md](./workspace/docs/10-invite-visibility.md)）

### データ保護

- [x] **Yes** — 秘密は環境変数／秘密管理のみ（Git に鍵を置かない）
- [x] **Yes** — バックアップ／リストア手順があり、staging で一度実演記録がある（[workspace/docs/09-backup-restore-drill.md](./workspace/docs/09-backup-restore-drill.md)、2026-08-21 Pass）
- [x] **Yes** — オブジェクト格納は S3 互換設定で差し替え可能（[media-platform/docs/07-customer-bucket.md](./media-platform/docs/07-customer-bucket.md)）

### 品質

- [x] **Yes** — Collab 依存リポの unit CI 緑（ローカル `go test` / `npm test` 運用。公開 Actions は各リポ CI）
- [x] **Yes** — 境界テスト（org 隔離、認可コード再利用拒否など）緑
- [x] **Yes** — 最小 E2E: ログイン → workspace ホーム → org 切替（`pf-workspace/apps/e2e`、同梱 IdP）
- [x] **Yes** — 依存の High 以上脆弱性は方針付き（[14-collab-slo-security.md](./14-collab-slo-security.md)。例外表はリリース都度）

### 可用性・観測（初期）

- [x] **Yes** — `/health` `/ready` が主要プロセスで応答
- [x] **Yes** — OTLP または同等で staging からメトリクス／トレースが取れる（o11y スタック）
- [x] **Yes** — アラート最低 1 本（Collector down 等）
- [x] **Yes** — 初期 SLO を文書化（[14-collab-slo-security.md](./14-collab-slo-security.md)。契約で上書き可）

### 監査

- [x] **Yes** — ログイン成功／失敗、トークン発行、org 切替、招待、権限変更など必須イベントが一覧化され出る（identity docs 08、workspace 監査イベント）
- [x] **Yes** — 保持期間方針がある（既定 90 日。[14-collab-slo-security.md](./14-collab-slo-security.md)。業種・地域は契約で確定）

### 名乗らない領域（明示）

次は **本番ゲート対象外**（別パッケージ／P16／外部 SaaS）。満たしていないことを顧客に隠さない。

- 給与計算・源泉／年末調整・法人会計フル ERP（→ P16（給与・税務）。当面は連携）
- 労基準拠を名乗った勤怠
- PCI 準拠の本格決済
- SAML のみの SSO（Enterprise 別。当面は OIDC）

## Go / No-Go

| 判定 | 条件 |
| --- | --- |
| **Go** | 上の Collab 必須ゲートがすべて Yes、または未充足項目ごとに Risk Accept（誰が・いつ見直すか）を記録 |
| **No-Go** | dev-auth が本番相当に残る、org 隔離テストが無い／落ちる、バックアップ未実演、ライセンスが評価のまま実課金運用 |

### 自己監査サマリ（2026-08-21）

| 判定 | **Go（Collab ゲート）** |
| --- | --- |
| ブロッカー | なし |
| 文書で閉じた項目 | 招待一枚絵、SLO 初期値、監査保持既定、脆弱性例外方針（[14-collab-slo-security.md](./14-collab-slo-security.md) / [10-invite-visibility.md](./workspace/docs/10-invite-visibility.md)） |
| 注意 | 評価 LICENSE のまま実課金運用は引き続き No-Go。顧客法務・例外表の実記入は契約時 |

再監査（同日）: staging バックアップ実演 Pass のあと、残 Risk Accept を書類で Yes に更新。

記録テンプレ: 日付、環境、チェック担当、Yes/No/Risk Accept、残課題。`08-commercial-roadmap.md` のマイルストーンと対応づける。

## 関連

- [06-verification.md](./06-verification.md) — 動作確認の層（L0〜L4）
- [19-collab-staging.md](./19-collab-staging.md)
- [20-commerce-staging.md](./20-commerce-staging.md)
- [14-collab-slo-security.md](./14-collab-slo-security.md)
- [10-package-catalog.md](./10-package-catalog.md)
- [12-portability.md](./12-portability.md)
- [08-commercial-roadmap.md](./08-commercial-roadmap.md)
- [15-licensing.md](./15-licensing.md)
- [16-cost-estimate.md](./16-cost-estimate.md)
