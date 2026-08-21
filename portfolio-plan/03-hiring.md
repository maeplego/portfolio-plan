# 採用担当者向け — まずここ（約 3 分）

| 項目 | 値 |
| --- | --- |
| 対象 | 採用担当・技術レビュア |
| 最終更新 | 2026-08-21 |

このポートフォリオは **学習・デモ・社内評価用** のソフトウェア群です。本番 SaaS の置き換えではありません。

## 一言で言うと

OpenID Connect の IdP を共有し、チーム作業・EC・勤怠などの製品を **別リポジトリ（`pf-*`）** に分けたエコシステムです。想定は「顧客環境にパッケージとして載せる」形で、常時ホスティングの自社 SaaS 本線ではありません。

## スコープ外（名乗っていないこと）

- 本番品質・SLA・無保証のままの有償利用（[15-licensing.md](./15-licensing.md)）
- PCI 準拠の決済、労働基準法準拠の勤怠、源泉・年末調整の法的正しさ
- AWS への `terraform apply`、15 製品の同時フル起動

## おすすめの見方（リポジトリ 3 本）

全部を追う必要はありません。次の 3 本で全体像が分かります。

1. **このメタリポジトリ** — 設計と本ページ
2. **画面のある本線** — [pf-workspace](https://github.com/maeplego/pf-workspace) または [pf-commerce](https://github.com/maeplego/pf-commerce)
3. **深さ 1 本** — [pf-identity](https://github.com/maeplego/pf-identity)（認証）、[pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y)（観測）、[pf-reliability](https://github.com/maeplego/pf-reliability)（インシデント訓練）のいずれか

## コードを見るときの観点

| 領域 | リポジトリ例 | 見てほしい点 |
| --- | --- | --- |
| 認証 | `pf-identity` | PKCE、redirect URI の扱い、refresh トークンの回転 |
| 本線 UI | `pf-workspace` または `pf-commerce` | ワークスペース作成、または在庫 1 の同時購入デモ（競合時は片方だけ成功） |
| 深さ | o11y / developer-portal / reliability / recommend | トレース、OpenAPI 破壊検知、訓練採点、推薦失敗時のフォールバックなど、いずれか 1 つ |

## 次に読む（手順）

手元で動かしたいときだけ → **[05-review.md](./05-review.md)**（ブラウザ確認 → Compose 1 パック）。

Kubernetes・商用 staging・ゲート判定は、採用時のざっとした確認の対象外です。必要なら REVIEW 末尾の「さらに知る」へ。

## 英語要約

See [04-hiring.en.md](./04-hiring.en.md).
