# いま

| 項目 | 値 |
| --- | --- |
| 書き方 | 毎回まるごと書き直す。値（HEAD など）は書かずに引く |
| 書いた手番 | 手番 6 |

## 止まっているもの（作者の答えだけが要るもの。六つまで）

| # | 止まっているもの | 待っているもの | ありか |
| --- | --- | --- | --- |
| 1 | 台帳の道具を作る（便 0001 を pf-オリーブに渡す） | 問 2〜6 の答え | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 1 |
| 2 | 器官の段（二周目の設計） | 問 7・問 8 の答え。材料は 3 のバンブー便で集める | 同 手番 1 |
| 3 | バンブー便（[bamboo/prompt_kikan_2026_10_08.md](./bamboo/prompt_kikan_2026_10_08.md)）を渡す | ペッパーの照らし。そのあと作者が二行で pf-バンブーを起こし、便を貼る | 同 手番 6 |
| 4 | renovation/ を master に入れるか | 問 15 の答え（3 の前に要る） | 同 手番 6 |
| 5 | 作者だけが書く掟の紙 `renovation/CLAUDE.md` | 作者が書く（決定 2。役は触らない） | 同 手番 4 |

1 の便（[olive/prompt_ledger_2026_10_08.md](./olive/prompt_ledger_2026_10_08.md)）の中の道は、旧い器（`portfolio-plan/renovation/attendance-payroll/`）のまま。渡す前に新しい道に直す。〔枝〕は決定 3（「区画/話題」の二段）に沿った案を、そのとき作者に出す。枝を名指しで取ること（罠帳 W-12）も便に書く。

## いつかやるもの（数とありかだけ）

| 数 | ありか |
| --- | --- |
| 4 件 | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 1「後で問う」（5 件のうち「pf-バンブーの役」は決定 4・決定 8 で済んだ） |
| 9 件 | [design/attendance-payroll/kikan.md](./design/attendance-payroll/kikan.md)「器官ではない直し」D1〜D9 |
| 1 件 | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 3「いつか」（2 件のうち「ペッパーの返事の型」は手番 6 で済んだ。残る「#N をどこに書くか」は、バンブーが読むだけの役になったので、今はオリーブだけ） |
| 1 件 | 同 手番 4「いつか」 |

## 引き方（値はここに書かない）

- 枝と HEAD: `git -C <portfolio-plan の道> status -sb`・`git -C <portfolio-plan の道> log --oneline -1`
- origin の枝: `git -C <portfolio-plan の道> ls-remote --heads origin`（罠帳 W-12）
- 決定 N・問 N・#N: [kiroku/](./kiroku/) を「決定 」「問 」「#」で探す
