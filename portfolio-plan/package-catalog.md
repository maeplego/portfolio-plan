# パッケージカタログ

| 項目 | 値 |
| --- | --- |
| 対象 | 機能パッケージ販売・提案・評価ライセンスとの差分説明 |
| 最終更新 | 2026-08-21 |

公開ソースは評価用（[licensing.md](./licensing.md)）。商用利用は別契約。現状の束は **コラボ＋基盤＋一部業務のデモ** であり、社内 ERP／給与税務フルスイートではない。

## 販売の切り方

| プラン（商用契約側） | 用途 | サポート・本番 | 機能 |
| --- | --- | --- | --- |
| 評価（公開 LICENSE） | 学習・社内 PoC・採用レビュー | 保証なし・本番不可 | リポジトリ現状 |
| Starter | 小規模本番・ collab 中心 | メールサポート、本番権、staging 手順 | Collab ゲート充足範囲 |
| Business | 複数 org・BYO IdP | 応答時間目安、障害 runbook | Collab + Foundation 寄せ |
| Enterprise | 監査・SLA・カスタム連携 | 個別契約、SAML 等は別見積 | 上記 + 合意した ports |

機能の大幅削りでプラン差を作らない。差は **用途・サポート・本番権・BYO 範囲** を優先する。

## パッケージ一覧

### Foundation（基盤）

- **含む**: P01 Identity（推奨同梱）、P02 観測／K8s 骨格、P03 Media（任意）
- **役割**: 他パッケージの前提。単体でも IdP＋観測デモ可
- **BYO**: IdP を顧客 OIDC に差し替え可（[portability.md](./portability.md)）。P01 は推奨アダプタ

### Collab（第一弾・商用最小の本線）

- **含む**: P04 Workspace。認証は Foundation の AuthPort（同梱 P01 または BYO IdP）。添付が要る構成では P03
- **含まない**: 給与・税務・会計、本格決済、労基名乗り勤怠
- **本番条件**: [production-definition.md](./production-definition.md)
- **依存**: Overlay B（collab）または同等 Compose

### Commerce path

- **含む**: P06 ± P07、P01、必要なら P03
- **商用化順**: Collab のあとの次パッケージ候補
- **注意**: 本格決済／PCI は別ゲート

### Talent path

- **含む**: P10、P05、P07、P01
- **用途**: 求人・面接枠。社内人事マスタ正本ではない

### Attendance（業務）

- **含む**: P09
- **注意**: デモ／学習品質の勤怠・工数。労基コンプラは名乗らない。給与連携は第 N 弾または外部 SaaS

### その他（カタログ掲載・商用は後続）

| パッケージ／製品 | メモ |
| --- | --- |
| Content（P08） | 技術ブログ＋短縮 |
| Developer（P11） | CLI／portal／CI／review／scanner |
| Reliability（P12） | インシデント＋ランブック訓練 |
| Data（P13） | ETL 骨格 |
| Personal finance（P14） | **個人家計**。法人会計ではない |
| Habit（P15） | 個人習慣。社内福利厚生ポータルではない |

## 対象外（当面）と第 N 弾（MN / P16）

次は **Collab〜近接パッケージの販売範囲に含めない**。提案時は既存 SaaS（freee、マネーフォワード、給与奉行等）連携を推奨する。

- 給与計算、社会保険控除、振込データ生成
- 源泉徴収・年末調整・法定調書
- 法人会計／仕訳 ERP、固定資産
- 経費精算の会計連動一式
- 電子契約の本格ライフサイクル

**商用第 N 弾** の受け皿は **P16 payroll-platform**（予約）。方針の正本は [mn-payroll-tax.md](./mn-payroll-tax.md)。実装はフル自前 ERP より **PayrollExportPort / AccountingPort** を優先し、法令レビューをゲートに含める。P09・P14 には載せない。

### Backoffice path（将来掲載）

- **含む（予定）**: P16 ± P01、入力ソースとして **P09**（必須寄り）。添付は任意で P03
- **含めない**: P14（個人家計）、Collab／Commerce 本体機能としての給与
- **今**: カタログ対象外。MN0–MN2 実装あり・**MN3（規制名乗り）未**。staging: [payroll-staging.md](./payroll-staging.md)
- **連携の正本**: [mn-payroll-tax.md](./mn-payroll-tax.md)「パッケージ販売時の連携」

## 関連

- [production-definition.md](./production-definition.md)
- [portability.md](./portability.md)
- [portability-byo-idp.md](./portability-byo-idp.md)
- [cost-estimate.md](./cost-estimate.md)
- [00-overview.md](./00-overview.md)
