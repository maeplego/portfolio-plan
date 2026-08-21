# 未実装・ギャップ実装計画（P01–P16）

| 項目 | 値 |
| --- | --- |
| 根拠 | [feature-audit](./README.md)、[11-implementation-backlog-by-pxx.md](../11-implementation-backlog-by-pxx.md) |
| 対象 | A（欠陥・契約不整合）と B（意図した未完了）のみ。C（意図的非目標）はやらない |
| 開始 | 2026-08-21 |
| 完了 | 2026-08-21（W0–W6） |

## 層

| 層 | 定義 |
| --- | --- |
| A | テスト赤、バグ、コードと要件の食い違い |
| B | DESIGN／デモ品質で揃える残り（docs 追随含む） |
| C | PCI、労基、給与規制名乗り、`terraform apply`、Kafka、動画、SAML、銀行 API など |

## ウェーブ

| 波 | 内容 | 状態 |
| --- | --- | --- |
| W0 | コード済み・docs 未の追随 | 済 |
| W1 | P01 org API テスト緑 | 済 |
| W2 | P02 overlay 文書、P03 purpose／404／etag／quota | 済 |
| W3 | P04 招待 URL／README、P06 exports proxy | 済 |
| W4 | P05 token／docs、P07 README、P10 docs | 済 |
| W5 | P08／P09／P12 docs＋最小認証・CORS | 済 |
| W6 | P13–P16 docs／OIDC 本検証／CI／habit PATCH | 済 |

## Pxx チェック

| ID | 層 | 項目 | 対応 |
| --- | --- | --- | --- |
| P01 | A | org API テスト 401 | 済（サーバ Clock とトークン期限を揃えた） |
| P01 | B | Discovery `org`、Compose デモ seed、docs `/v1` org | 済 |
| P02 | B | overlay-matrix 追随、最小 5xx/p95 ルール | 済 |
| P03 | A/B | purpose 許可、他人 GET 404、etag、quota org、共有一覧／削除 | 済 |
| P04 | A/B | 招待 URL 3006、README 招待本線 | 済 |
| P05 | B | INTERNAL_TOKEN 例、docs webhook 実装済、demo-catalog | 済 |
| P06 | B | gateway exports proxy、AGENTS/README、recommend 障害 | 済 |
| P07 | B | README commerce／手動 retrain | 済 |
| P08 | B | レート制限 README、infra OIDC env | 済 |
| P09 | B | docs/05-api、CORS Org、README SES/PDF | 済 |
| P10 | B | シード件数、staging 応募手順 | 済 |
| P11 | B | portal PORTAL_*_URL 明示、K8s 非搭載一覧 | 済 |
| P12 | A/B | docs ランブック、一覧 GET 認証 | 済 |
| P13 | B | commerce コネクタ docs、pyproject 文言 | 済 |
| P14 | B | Compose が起動の正 | 済 |
| P15 | B | 通知・同期 docs、habit PATCH/archive | 済 |
| P16 | B | OIDC JWKS、CI、顧客向け一文 | 済 |

C は各 feature-audit の非目標どおり据え置き。
