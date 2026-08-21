# 機能再確認（feature-audit）

各 Pxx の **いま実装されている能力** を、設計・製品コード・デモ入口から突き合わせた監査メモ。

| 項目 | 値 |
| --- | --- |
| 目的 | 就職・商用説明の前に「何ができて何を名乗らないか」を再確認する |
| 正本の優先 | テストとコード → `DESIGN.md` → 本フォルダ → 古い docs |
| 対象 | **P01–P16 すべて**（2026-08-21 時点） |
| 最終更新 | 2026-08-21 |

## 索引

| ID | ファイル | 製品リポ | 状態 |
| --- | --- | --- | --- |
| P01 | [P01-identity.md](./P01-identity.md) | `pf-identity` | 済 |
| P02 | [P02-cloud.md](./P02-cloud.md) | `pf-cloud-o11y` / `pf-cloud-k8s` / `pf-cloud-aws` | 済 |
| P03 | [P03-media.md](./P03-media.md) | `pf-media` | 済 |
| P04 | [P04-workspace.md](./P04-workspace.md) | `pf-workspace` | 済 |
| P05 | [P05-calendar.md](./P05-calendar.md) | `pf-calendar` | 済 |
| P06 | [P06-commerce.md](./P06-commerce.md) | `pf-commerce` | 済 |
| P07 | [P07-recommend.md](./P07-recommend.md) | `pf-recommend` | 済 |
| P08 | [P08-content.md](./P08-content.md) | `pf-content-blog` / `shortener` / `infra` | 済 |
| P09 | [P09-attendance.md](./P09-attendance.md) | `pf-attendance` | 済 |
| P10 | [P10-talent.md](./P10-talent.md) | `pf-talent-api` / `pf-talent-web` | 済 |
| P11 | [P11-developer.md](./P11-developer.md) | `pf-developer-*`（6 リポ） | 済 |
| P12 | [P12-reliability.md](./P12-reliability.md) | `pf-reliability` | 済 |
| P13 | [P13-data.md](./P13-data.md) | `pf-data` | 済 |
| P14 | [P14-finance.md](./P14-finance.md) | `pf-finance` | 済 |
| P15 | [P15-habit.md](./P15-habit.md) | `pf-habit-mobile` / `pf-habit-api` | 済 |
| P16 | [P16-payroll.md](./P16-payroll.md) | `pf-payroll` | 済 |

## 横断でよく出るギャップ

| テーマ | 例 |
| --- | --- |
| docs 遅れ | 実装計画 W0 で P05 webhook／P12 ランブック／P13 commerce／P15 通知・同期／P08 レート制限を追随。残りは [implementation-plan.md](./implementation-plan.md) |
| 採用既定 vs K8s | Compose／review pack が既定。P05 は review pack に無し。P11 は portal のみ K8s |
| 名乗らない | P09 労基、P16 税務・給与準拠、P14 実口座、P06 PCI |
| 認証 | 単体は多くが DEV_AUTH。staging overlay で拒否 |

## 読み方

- 採用スキムの入口ではない。入口は [03-hiring.md](../03-hiring.md)。
- 各ファイルは同じ見出し構成（識別 → 機能 → デモ → 契約 → 非目標 → ギャップ）。
- 矛盾したらテストとコードが正。

## 関連

- 全体地図: [00-overview.md](../00-overview.md)
- 実装棚卸し: [11-implementation-backlog-by-pxx.md](../11-implementation-backlog-by-pxx.md)
- 実装計画: [implementation-plan.md](./implementation-plan.md)
