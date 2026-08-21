# P16 payroll-platform

| 項目 | 値 |
| --- | --- |
| 状態 | **MN1 実装中**（`pf-payroll`） |
| 製品リポジトリ | `../pf-payroll` |
| 最終更新 | 2026-08-21 |

## 目的

法人向けの **給与連携・（将来）薄い給与／税務ドメイン** を、勤怠（P09）や個人家計（P14）と分けて持つ。商用マイルストーン MN の受け皿。

## スタック（MN1）

- API: TypeScript + Hono（`pf-payroll`）
- Store: メモリ（MN1）。Postgres は MN2 以降
- 認証: `PAYROLL_ENV` staging/production で DEV_AUTH 拒否。OIDC フル検証は後続

## 実装順

1. [x] `PayrollExportPort` + モック + P09 `minutes-v1` CSV 取り込み
2. [x] `AccountingPort` モック（分数量の仕訳 DTO。円ではない）
3. [ ] staging overlay 入口
4. [ ] デモ用明細プレビュー UI
5. [ ] docs 01–06（デモ塊が揃ってから）

## 他 Pxx との契約

- **P09 → P16**: `GET /v1/months/{month}/export.csv`、ヘッダ `X-Attendance-Export-Contract: minutes-v1`。金額列なし
- **P16 → 外部**: モック PayrollExport / Accounting。自前準拠は名乗らない
- **P14**: 参照しない

## API（MN1）

| 方法 | パス | 内容 |
| --- | --- | --- |
| GET | `/health` `/ready` | 生存 |
| GET | `/v1/disclaimer` | 法的効力なしの明示 |
| POST | `/v1/imports/attendance-csv` | P09 CSV 本文 |
| POST | `/v1/exports/payroll` | モック給与 SaaS へ |
| POST | `/v1/exports/accounting` | モック会計へ（分のみ） |

## 非目標

- 労基・税務の「準拠」名乗り（MN3 ゲート前）
- P09 への給与ロジック混入
- 電子申告本線、マイナンバー本保管
- フル ERP

## デモ観点

1. staging で DEV_AUTH 起動拒否（単体テスト）
2. 架空 CSV → import → mock payroll / accounting receipt（`npm test`）
3. 応答に `legalEffect: false` と disclaimer
