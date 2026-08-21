# 採用担当者向け — まずここ（約 3 分）

| 項目 | 値 |
| --- | --- |
| 対象 | 採用担当・技術レビュア |
| 最終更新 | 2026-08-21 |

このポートフォリオは **学習・デモ・社内評価用** のソフトウェア群です。本番 SaaS の置き換えではありません。

## 一言で言うと

OpenID Connect の IdP を共有し、チーム作業・EC・勤怠などの製品を **別リポジトリ（`pf-*`）** に分けたエコシステムです。売りの物語は「顧客環境にパッケージとして載せる」想定で、常時ホスティングの自社 SaaS 本線ではありません。

## 名乗らないこと

- 本番品質・SLA・無保証のままの有償利用（[licensing.md](./licensing.md)）
- PCI 準拠の決済、労働基準法準拠の勤怠、源泉・年末調整の法的正しさ
- AWS への `terraform apply`、15 製品の同時フル起動

## GitHub で見る 3 本（ピン想定）

1. **このメタリポジトリ**（設計と本ページ）
2. **画面のある本線** — [pf-workspace](https://github.com/maeplego/pf-workspace) または [pf-commerce](https://github.com/maeplego/pf-commerce)
3. **深さ 1 本** — [pf-identity](https://github.com/maeplego/pf-identity)（認証）、[pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y)（観測）、[pf-reliability](https://github.com/maeplego/pf-reliability)（訓練）のいずれか

## 口頭 3 点（約 5 分）

1. **認証** — PKCE、redirect 一致、refresh 回転（`pf-identity`）
2. **本線** — ワークスペース作成、または EC の在庫 1 同時購入デモ（片方だけ成功）
3. **深さ** — トレース／OpenAPI 破壊検知／訓練採点／推薦 fail-closed のいずれか 1 つ

## 次に読む（手順）

手元で動かしたいときだけ → **[REVIEW.md](./REVIEW.md)**（ブラウザ 5 分 → Compose 1 パック）。

Kubernetes・商用 staging・ゲート判定は採用スキムの対象外です。興味があれば末尾の「さらに知る」へ。

## 英語要約

See [HIRING.en.md](./HIRING.en.md).
