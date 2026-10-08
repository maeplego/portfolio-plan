# 便 0003 — pf-ユーカリ → pf-オリーブ「便 0002 の合流（二つ）・問の番号・pf-attendance の依存」

| 項目 | 値 |
| --- | --- |
| 状態 | 手番 17 に直した（ペッパーの照らしの 1〜3 と、#20 の一行）。直した所はペッパーが照らした（手番 18）。作者がオリーブの窓に貼った（手番 19）。一度目の報告が来た（手番 20）: 1 は済み。3 は npm run build が、master にもとからある型の誤りで落ち、作る前に止まった（問 35） |
| 渡す条件 | 渡した（手番 19。作者「オリーブに便を渡したよ。」）。便 0002 を渡したオリーブの窓 |
| 書いた日 | 2026-10-08（手番 16。手番 17 に直した） |
| もと | 決定 31（問 25 → あ）・決定 32（問 26 → あ）・決定 33（問の番号はユーカリ）。[kiroku/2026_10_08.md](../kiroku/2026_10_08.md) 手番 14〜17 |

下の囲みの中を、そのまま貼る。

```text
（pf-ユーカリから pf-オリーブへの便 0003 —— 作者が貼って渡す）

pf-オリーブへ。オリーブ問 2 への作者の答えと、問の番号の決まりと、次の仕事を渡します。設計と記録は pf-ユーカリ、決めるのは作者です。読むものは便 0002 と同じです（renovation/ は枝 claude/dazzling-franklin-c45tgk のもの）。決定 31〜33 は、その枝の renovation/kiroku/2026_10_08.md の手番 16 にあります。

■ 1. オリーブ問 2 への作者の答え（ユーカリの問 25 → あ。決定 31）
- portfolio-plan と pf-payroll の ci/trigger は、master に合流してよい（作者の「はい」）。--no-ff で。押す命令は一つずつ出し、断られたらそこで止める（罠帳 W-19）。
- 合流のあと、二つの master の走りが緑になることを確かめる（便 0002 の守ること 4）。
- pf-attendance の ci/trigger は、まだ合流しない。下の 3 が master に入ってから。

■ 2. 問の番号（決定 33）
- これからは、問に番号を振らない。番号はユーカリが振る。
- 問を出すときは「問（番号はユーカリが振る）」と書き、選択肢 あ／い／う・見立て・答えの型「問（番号はユーカリ）：［ ］」を添える。
- 前の「問 1」「問 2」は、記録では「オリーブ問 1」「オリーブ問 2」と書いてある。

■ 3. pf-attendance の apps/web の依存を上げる（ユーカリの問 26 → あ。決定 32）
- 変えるのは apps/web/package-lock.json だけ。package.json は変えない。.trivyignore にも足さない（O-5）。
- 枝: web/deps（決定 3 の形。区画は apps/web）。master の最新から切る。窓が別の名の枝を渡していても、この名で作る（作者の許し）。上流は付けない。押すときは名指しで。
- 上げる版（一度目の報告の五件を消す）:
  - next: 15 の中で 15.5.24 以上（package.json の ^15.1.0 の中）
  - sharp: 0.35.5 以上（next 15.5.24 は sharp を ^0.34.3 || ^0.35.3 で求める。ユーカリが npm の記録で測った）
  - source-map-js: 1.2.2 以上（postcss 8.4.31 が ^1.0.2 で求める）
- やり方は任せる（例: apps/web で npm update next sharp source-map-js）。package.json に差が出たら、作る前に止まって報告する。
- 確かめ:
  - 最初に node -v。20.9 より古ければ、止まって報告する（sharp 0.35 は node 20.9 以上を求める）。
  - apps/web で npm ci と npm run build が通る（apps/web には試験が無い）。
  - lockfile に @img/sharp-linuxmusl-x64・@img/sharp-linuxmusl-arm64・@img/sharp-libvips-linuxmusl-x64・@img/sharp-libvips-linuxmusl-arm64 が残っている（apps/web の Dockerfile は node:22-alpine の中で npm ci をする。CI は image を作らないので、抜けても CI は緑のまま）。抜けていたら、作る前に止まって報告する。
  - web/deps に押すと、master の前の形の ci.yml で CI が走る（四つのジョブ）。trivy を含む四つが緑になる。走らなければ、止まって報告する（その ci.yml には workflow_dispatch が無く、手では走らせられない）。
  - trivy がほかの脆弱性を出したら、どこにも足さずに止まって報告する。
- web/deps の master への合流は、作者の「はい」のあと（--no-ff）。合流のあと master の走りが緑なら、続けて pf-attendance の ci/trigger も合流する（同じ「はい」で）。master が赤なら、そこで止まる。

■ 守ること
- cd は使わず、git -C と絶対の道で。--no-verify・--amend・force・rebase は使わない。
- コミットは意図の単位で。本文に「なぜ」を書く。
- 秘密は書かない。

■ 終わりの形
- 一度目: 1 の合流と master の走り、3 の web/deps（押して、CI の結果が出たところ）まで。ここで止まって報告する。
- 二度目: 作者の「はい」で web/deps と pf-attendance の ci/trigger を合流したあと、master の走りを確かめて報告する。
- 報告に書くこと:
  - 1: 二つの合流のコミットと、master の走り（run の番号と結果）
  - 3: node -v の結果。lockfile で変わった版（next・sharp・source-map-js）と、linuxmusl の四つが残っていること。package.json に差が無いこと。npm ci と build の結果。web/deps の CI の run と結果（trivy の件数）
  - 自分の間違い（#N。オリーブの通し番号。O-9）
  - 迷ったこと
  - 問（番号は振らない。2 のとおり）
- 報告は作者に渡す。ユーカリへは作者が貼る。

★ 決めるのは作者
```

## 設計の訳（ユーカリ）

| どこ | 訳 |
| --- | --- |
| 便を一つにまとめた | 作者の「それも踏まえてオリーブへの便を用意してください。」（手番 16）。同じ窓に一度で貼れる |
| web/deps を master から切る | 依存の上げを、CI のきっかけの変え（ci/trigger）と混ぜないため。master の ci.yml はまだ前の形なので、web/deps に押すと CI が走り、それが合流の前の確かめになる |
| 一つの「はい」で二つ合流 | web/deps のあとに ci/trigger を入れれば、master の走りは新しい ci.yml の初めの走りになる。master が赤なら止まるので、赤のまま ci/trigger は入らない |
| 版の下限 | 手番 15 に npm の記録で測った（next 15.5.24 の sharp の範囲、sharp 0.35.4・0.35.5、source-map-js 1.2.2 があること）。上限は package.json と依存の範囲に任せる |
| 手で走らせる一行を直した（手番 17） | web/deps は master から切るので、ci.yml は前の形（on: push と pull_request だけ）で、workflow_dispatch が無い【測】。手番 14 に手で走ったのは、枝の ci.yml にその一行があったから（#19。ペッパーの照らし 1） |
| node と linuxmusl の確かめ（手番 17） | sharp 0.35.4・0.35.5 の engines は node >=20.9.0【測】。Dockerfile は node:22-alpine の中で npm ci をし、CI は image を作らない【測】。lockfile を取り直すと、ほかの OS 向けの任意の依存が抜けることがある【推】（ペッパーの照らし 2・3） |
| 答えの届け方の一行を抜いた（手番 17） | 「作者の答えは、ユーカリの番号で、ユーカリの便として届く。」は作者の言葉に無く、手番 16 の「★ 私が決めた範囲」にも書いていなかった（#20。ペッパーの照らし 4）。どう届けるかは問 31 |
