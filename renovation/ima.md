# いま

| 項目 | 値 |
| --- | --- |
| 書き方 | 毎回まるごと書き直す。値（HEAD など）は書かずに引く |
| 書いた手番 | 手番 8 |

## 止まっているもの（作者の答えだけが要るもの。六つまで）

| # | 止まっているもの | 待っているもの | ありか |
| --- | --- | --- | --- |
| 1 | バンブー便（[bamboo/prompt_kikan_2026_10_08.md](./bamboo/prompt_kikan_2026_10_08.md)）を渡す | 作者が二行で pf-バンブーを起こし、「書き写す三つ」が返ったら便を貼る（手番 8 で足した一行を照らすかは作者） | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 8 |
| 2 | オリーブ便 0001（[olive/prompt_ledger_2026_10_08.md](./olive/prompt_ledger_2026_10_08.md)）を渡す | 問 18 の答え（あ ならこのまま）。ペッパーの照らし。そのあと作者が二行で pf-オリーブを起こし、便を貼る | 同 手番 8 |
| 3 | 手番 8 の分を master に入れるか | 問 19 の答え | 同 手番 8 |
| 4 | 作者だけが書く掟の紙 `renovation/CLAUDE.md` | 作者が書く（決定 2。役は触らない） | 同 手番 4 |

renovation/ は master に入った（決定 18。手番 7 のマージ）。master は次のマージまで枝より遅れるので、便には枝を名指しで取る一行を入れ続ける（罠帳 W-12）。次のマージも作者の「はい」のあと（O-10）。

呼び名は決定 19: 「ペッパー」は pf-ペッパー。Cambium のペッパーの役は終わった（決定 21）。便を照らすのはペッパー。

器官の段（二周目）は、台帳（一周目。2 の便）のあと。器官を入れる順番は、そのとき問う（手番 1「後で問う」）。

## いつかやるもの（数とありかだけ）

| 数 | ありか |
| --- | --- |
| 4 件 | [kiroku/2026_10_08.md](./kiroku/2026_10_08.md) 手番 1「後で問う」（5 件のうち「pf-バンブーの役」は決定 4・決定 8 で済んだ） |
| 9 件 | [design/attendance-payroll/kikan.md](./design/attendance-payroll/kikan.md)「器官ではない直し」D1〜D9（直し方は決定 15） |
| 1 件 | 同 手番 4「いつか」 |

手番 3 の「いつか」は二件とも、ほかで受けた（「ペッパーの返事の型」は手番 6 で済んだ。「#N をどこに書くか」は問 18）。

## 引き方（値はここに書かない）

- 枝と HEAD: `git -C <portfolio-plan の道> status -sb`・`git -C <portfolio-plan の道> log --oneline -1`
- origin の枝: `git -C <portfolio-plan の道> ls-remote --heads origin`（罠帳 W-12）
- master へのマージ: `git -C <portfolio-plan の道> log --merges --first-parent --oneline origin/master`
- 逐語の印の数: `git -C <portfolio-plan の道> grep -E '^<!-- VERBATIM:[^ ]+ -->$' -- renovation | wc -l`（行の頭から終わりまでが印の形の行だけ。罠帳 W-14）
- 決定 N・問 N・#N: [kiroku/](./kiroku/) を「決定 」「問 」「#」で探す
