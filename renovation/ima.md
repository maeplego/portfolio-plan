# いま

| 項目 | 値 |
| --- | --- |
| 書き方 | 毎回まるごと書き直す。値（HEAD など）は書かずに引く |
| 書いた手番 | 手番 7 |

## 止まっているもの（作者の答えだけが要るもの。六つまで）

| # | 止まっているもの | 待っているもの | ありか |
| --- | --- | --- | --- |
| 1 | オリーブ便 0001（[olive/prompt_ledger_2026_10_08.md](./olive/prompt_ledger_2026_10_08.md)）を渡す | 問 17 の答え（枝の名）。そのあと Cambium のペッパーの照らし。作者が二行で pf-オリーブを起こし、便を貼る | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 7 |
| 2 | バンブー便（[bamboo/prompt_kikan_2026_10_08.md](./bamboo/prompt_kikan_2026_10_08.md)）を渡す | Cambium のペッパーの照らし（手番 7 で直した所）。そのあと作者が二行で pf-バンブーを起こし、便を貼る | 同 手番 7 |
| 3 | 呼び名を書き分けるか（Cambium のペッパーと pf-ペッパー） | 問 16 の答え | 同 手番 7 |
| 4 | 作者だけが書く掟の紙 `renovation/CLAUDE.md` | 作者が書く（決定 2。役は触らない） | 同 手番 4 |

renovation/ は、手番 7 のコミットのあと master に入れる（決定 18）。master は次のマージまで遅れるので、便には枝を名指しで取る一行を入れ続ける（罠帳 W-12）。次のマージも作者の「はい」のあと（O-10）。

器官の段（二周目）は、台帳（一周目。1 の便）のあと。器官を入れる順番は、そのとき問う（手番 1「後で問う」）。

## いつかやるもの（数とありかだけ）

| 数 | ありか |
| --- | --- |
| 4 件 | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 1「後で問う」（5 件のうち「pf-バンブーの役」は決定 4・決定 8 で済んだ） |
| 9 件 | [design/attendance-payroll/kikan.md](./design/attendance-payroll/kikan.md)「器官ではない直し」D1〜D9（直し方は決定 15） |
| 1 件 | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 3「いつか」（2 件のうち「ペッパーの返事の型」は手番 6 で済んだ。残る「#N をどこに書くか」は、バンブーが読むだけの役になったので、今はオリーブだけ） |
| 1 件 | 同 手番 4「いつか」 |

## 引き方（値はここに書かない）

- 枝と HEAD: `git -C <portfolio-plan の道> status -sb`・`git -C <portfolio-plan の道> log --oneline -1`
- origin の枝: `git -C <portfolio-plan の道> ls-remote --heads origin`（罠帳 W-12）
- master へのマージ: `git -C <portfolio-plan の道> log --merges --first-parent --oneline origin/master`
- 決定 N・問 N・#N: [kiroku/](./kiroku/) を「決定 」「問 」「#」で探す
