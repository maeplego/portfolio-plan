# P16 payroll-platform

| 項目 | 値 |
| --- | --- |
| 状態 | **デモ段階**（明細プレビュー UI + デモレート） |
| 製品リポジトリ | `../pf-payroll` |
| 最終更新 | 2026-08-21 |

## 目的

法人向けの **給与連携・薄いデモ明細** を、勤怠（P09）や個人家計（P14）と分けて持つ。商用製品 P16 の受け皿。

## スタック

- API + 薄い UI: TypeScript + Hono（同一プロセス。`GET /`）
- Store: メモリ（デモレート含む）
- 認証: `PAYROLL_ENV` staging/production で DEV_AUTH 拒否

## 実装順

1. [x] `PayrollExportPort` + モック + P09 `minutes-v1` CSV 取り込み
2. [x] `AccountingPort` モック（分数量の仕訳 DTO。円ではない）
3. [x] デモ用明細プレビュー UI（常時 disclaimer）
4. [x] デモ従業員レート（税率表・実賃金表ではない）
5. [x] staging overlay 入口（`docker-desktop-f-ops-staging` + `payroll.localhost`）
6. [ ] docs 01–06（デモ塊が揃ってから。P16-規制名乗り 前は規制名乗りなし）

## 他 Pxx との契約

- **P09 → P16**: `minutes-v1` CSV。金額列なし
- **P16 → 外部**: モック Export。自前準拠は名乗らない
- **P14**: 参照しない

## API

| 方法 | パス | 内容 |
| --- | --- | --- |
| GET | `/` | 明細 UI（免責バナー常時） |
| GET | `/health` `/ready` | 生存 |
| GET | `/v1/disclaimer` | 法的効力なし |
| POST | `/v1/imports/attendance-csv` | P09 CSV（`?month=` 任意） |
| GET/PUT | `/v1/demo-rates` | フィクション時給 |
| GET | `/v1/statements/preview` | 明細プレビュー |
| POST | `/v1/exports/payroll` | モック給与 SaaS |
| POST | `/v1/exports/accounting` | モック会計（分のみ） |

## 非目標

- 労基・税務の「準拠」名乗り（規制名乗り前）
- P09 への給与ロジック混入
- 電子申告本線、マイナンバー本保管
- フル ERP

## デモ観点

1. `http://127.0.0.1:8020/` に免責が常時表示
2. CSV import → preview に demo gross ¥（fiction タグ）
3. `legalEffect: false`

## 関連

- [payroll-tax-policy.md](./payroll-tax-policy.md)
