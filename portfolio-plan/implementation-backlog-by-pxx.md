# 各 Pxx：実装必須／推奨（商用ゲート視点）

| 項目 | 値 |
| --- | --- |
| 対象 | P01–P15 の商用化・デモ品質ギャップ棚卸し |
| 最終更新 | 2026-08-21 |
| 前提 | パッケージ販売順は [commercial-roadmap.md](./commercial-roadmap.md)。本番定義は [production-definition.md](./production-definition.md)。確認層は [verification.md](./verification.md) |

**必須** = そのパッケージを「商用／顧客 PoC に実データ可」と名乗る前に揃えるもの。  
**推奨** = デモ・採用・運用の質を上げるが、名乗らなければ後回し可。  
**意図的非目標** = 当面やらない（カタログ／契約で明示）。

---

## 横断（全パッケージ共通）

| 優先 | 内容 |
| --- | --- |
| 必須（商用名乗るとき） | `*_ENV=staging\|production` で DEV_AUTH／一時鍵拒否、OIDC（または承認済み AuthPort）、`/health` `/ready`、秘密の env のみ |
| 必須（Collab 級） | org／テナント隔離、バックアップ実演、監査イベント、staging スモーク |
| 推奨 | OTLP、最低 1 アラート、顧客バケット／BYO 手順、最小 E2E |
| 非目標 | 15 製品同時本番、SAML 必須化、PCI／労基／給与税務の名乗り（→ MN） |

---

## P01 identity（Foundation）

| | |
| --- | --- |
| **状態** | `IDENTITY_ENV` staging/production 実装済み。監査・脅威モデル書類あり |
| **必須（残り）** | 顧客本番鍵ローテ runbook の実演記録（Collab と共有可） |
| **推奨** | JWKS 多鍵、Admin 本番ハードニング、レート制限の文書化 |
| **非目標** | 公開常時 IdP、SAML のみ SSO |

## P02 cloud（o11y / k8s / aws）

| | |
| --- | --- |
| **状態** | Compose／overlay デモ、Collector down アラート骨格。Terraform は validate まで |
| **必須（商用 Collab/Commerce を載せるとき）** | staging overlay の再現手順、秘密の Secret 管理、観測の最小アラート |
| **推奨** | バックアップ／リストアのプラットフォーム側手順、dashboards の顧客向け薄いセット |
| **非目標** | `terraform apply` 本番必須、全 overlay 同時フル起動 |

## P03 media（Foundation 寄り）

| | |
| --- | --- |
| **状態** | S3 互換・顧客バケット手順あり。`MEDIA_ENV` で staging DEV_AUTH 拒否済み |
| **必須（添付付き Collab/Commerce）** | staging で `MEDIA_DEV_AUTH=false` + OIDC、顧客バケット疎通 |
| **推奨** | ウイルススキャン／CDN（名乗るなら別ゲート）、派生ジョブの DLQ 運用 |
| **非目標** | 動画変換フル、クライアント E2E 暗号化 |

## P04 workspace（Collab・第一弾）

| | |
| --- | --- |
| **状態** | M2 **Go**（ゲート・バックアップ実演・E2E・staging overlay） |
| **必須（残り）** | 評価 LICENSE→商用契約、顧客環境での秘密／SLO 確定 |
| **推奨** | 招待一枚絵の顧客向けデザイン、脆弱性例外表の実記入、chat/collab 分割デプロイ |
| **非目標** | 給与・税務、メール Push 本格 |

## P05 calendar

| | |
| --- | --- |
| **状態** | Compose／OIDC 可。`CALENDAR_DEV_AUTH` 既定オン。**ENV プロファイルなし** |
| **必須（Talent path 商用時）** | `CALENDAR_ENV` + staging で DEV_AUTH 拒否、org クレーム方針 |
| **推奨** | ホストタイムゾーン／重複予約の境界テスト拡充、E2E |
| **非目標** | 勤怠との統合 |

## P06 commerce（M3 本線）

| | |
| --- | --- |
| **状態** | `COMMERCE_ENV`（gateway/order）、staging overlay、cluster smoke **Pass**（2026-08-21） |
| **必須（Commerce Go）** | バックアップ実演（Collab 手順流用可）、ゲート自己監査、決済はモックのまま明示 |
| **推奨** | BFF/storefront の staging 強制ログイン、在庫同時購入の staging 回帰、recommend 障害時フォールバック文書 |
| **非目標** | PCI 本格決済、実カード |

## P07 recommend

| | |
| --- | --- |
| **状態** | 推論 API・学習パイプライン。認証は利用側依存 |
| **必須（Commerce/Talent 商用時）** | モデル／データの版管理方針、フォールバック動作の文書 |
| **推奨** | レイテンシ SLO、再学習 runbook |
| **非目標** | 巨大 npy を Git 管理 |

## P08 content（blog / shortener）

| | |
| --- | --- |
| **状態** | デモ品質。`CONTENT_DEV_AUTH` / `SHORTENER_DEV_AUTH`。shortener は OIDC 未配線 |
| **必須（Content パッケージ商用時）** | ENV プロファイル、OIDC、下書き公開範囲 |
| **推奨** | OG／RSS の運用、短縮 URL の濫用対策 |
| **非目標** | 本番 CMS・メディア企業向け編集ワークフロー |

## P09 attendance

| | |
| --- | --- |
| **状態** | Web OIDC 配線あり。API 側 ENV／DEV_AUTH プロファイルは薄い／未整備 |
| **必須（Attendance 商用・名乗らない前提でも PoC）** | `ATTENDANCE_ENV`、DEV_AUTH オフ、org、バックアップ |
| **推奨** | 打刻改ざん耐性のテスト、カレンダー連携 |
| **非目標** | 労基準拠を名乗った勤怠、給与連携（→ MN） |

## P10 talent

| | |
| --- | --- |
| **状態** | `TALENT_ENV` staging/production で DEV_AUTH 拒否済み |
| **必須（Talent path 商用）** | staging overlay、org 隔離テスト、calendar 連携の staging、バックアップ |
| **推奨** | recommend 連携のフォールバック、面接枠の E2E |
| **非目標** | 社内人事マスタ正本 |

## P11 developer

| | |
| --- | --- |
| **状態** | 公開 GitHub 読み取り中心。K8s overlay に一部 portal |
| **必須（Developer パッケージ販売時）** | PAT を Git に置かない運用の徹底、権限スコープ文書 |
| **推奨** | CI dash／review の顧客向け導入ガイド |
| **非目標** | exploit／PoC、ローカル git パス受付（review） |

## P12 reliability

| | |
| --- | --- |
| **状態** | デモ。`RELIABILITY_DEV_AUTH` 必須スライス（OIDC 未配線） |
| **必須（Reliability 商用時）** | OIDC、ENV プロファイル、合成アラートと本番コマンド非実行の明示維持 |
| **推奨** | ランブック訓練シナリオ拡充 |
| **非目標** | 本番 kubectl 自動修復ボット |

## P13 data

| | |
| --- | --- |
| **状態** | 架空 CSV ETL。Compose 中心 |
| **必須（Data 商用時）** | ソース契約（P06 本番エクスポートを偽らない）、失敗時 staging 非更新の維持 |
| **推奨** | Dagster 運用 runbook、品質メトリクス |
| **非目標** | 顧客本番データの勝手な複製 |

## P14 personal-finance

| | |
| --- | --- |
| **状態** | `FINANCE_DEV_AUTH`。個人家計デモ |
| **必須（個人向け有償時）** | ENV プロファイル、OIDC、実家計・実カード禁止の維持 |
| **推奨** | sync 競合テスト、PWA オフライン |
| **非目標** | 法人会計 ERP |

## P15 habit

| | |
| --- | --- |
| **状態** | `HABIT_DEV_AUTH` / OIDC。モバイルは K8s 非目標 |
| **必須（有償同期時）** | API の staging プロファイル、実在ログ禁止 |
| **推奨** | モバイル E2E、競合マージ |
| **非目標** | 福利厚生ポータル化、モバイルの K8s 載せ |

---

## 推奨の実装順（残り）

1. **P06** Commerce cluster staging スモーク完了 → ゲート自己監査（M3）
2. **P03** staging overlay／Compose で `MEDIA_ENV` 適用をデモ経路に載せる
3. **P10 + P05** Talent／Calendar の ENV + staging overlay（Talent path）
4. **P09** Attendance ENV（労基は名乗らないまま）
5. **P08 / P12 / P14 / P15** はカタログ後続。ENV パターンをコピーするだけでも価値あり
6. **MN** 給与税務は Collab〜Attendance のあと

## 関連

- [commercial-roadmap.md](./commercial-roadmap.md)
- [package-catalog.md](./package-catalog.md)
- [commerce-staging.md](./commerce-staging.md)
- [collab-staging.md](./collab-staging.md)
