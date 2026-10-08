# 便 0001 — pf-ユーカリ → pf-オリーブ「台帳の道具を作る」

| 項目 | 値 |
| --- | --- |
| 状態 | できた。渡す条件がそろった（便 0002・0003 は master に入った。決定 44。枝は手番 28 に docs/eucalyptus に切り替えた。決定 47）。ペッパー（pf-ペッパー）が照らしてから、作者が貼る |
| 渡す条件 | 便 0002・0003 が master に入り、枝を切り替えたあと（決定 26・37）。「対象」の renovation/ を読む一行は、手番 25 に枝 docs/eucalyptus に直した（決定 35）。ペッパーの照らし。作者が貼る（便 0002 と同じ窓でよい。新しい窓なら、二行で起こして「書き写す三つ」が返ってから） |
| 書いた日 | 2026-10-08（手番 1）。手番 7 で決定 11〜14 を入れ、道を今の器に直した。手番 8 で枝の名（決定 20）を、手番 10 で CI の決まり（決定 24）を、手番 18 で問と答え（決定 33・39）を、手番 26 で枝を消す頼み（決定 46）を、手番 28 で cd を使わない命令の形（罠帳 W-29）を入れた |
| もと | [design/attendance-payroll/daicho.md](../design/attendance-payroll/daicho.md)・決定 11〜15（[README.md](../design/attendance-payroll/README.md)） |

下の囲みの中を、そのまま貼る。

```text
（pf-ユーカリから pf-オリーブへの便 0001 —— 作者が貼って渡す）

pf-オリーブへ。この便で頼むのは「台帳の道具を作る」段だけです。器官（夜勤・残業の区分など）とスイッチは、まだ作りません。設計と記録は pf-ユーカリ、決めるのは作者です。

■ 0. 先に、合流が済んだ枝を消す（決定 46）
- 消すのは四本: portfolio-plan の ci/trigger、pf-payroll の ci/trigger、pf-attendance の ci/trigger と web/deps。どれも master に合流済み。
- 消す前に、一本ずつ、枝の先が master の祖先かを確かめる（git -C <道> ls-remote --heads origin <枝> で先を取り、git -C <道> merge-base --is-ancestor <先> origin/master）。祖先でなければ、消さずに止まって報告する。
- 消すのは git -C <道> push origin --delete <枝>。押す命令は一つずつ出し、断られたらそこで止める（罠帳 W-19）。
- これからの作業の枝（下の ledger/first-pass も）は、合流して master の走りが緑になったら、同じように消す（決定 46）。docs の枝（docs/eucalyptus）は消さない。

■ 対象
- maeplego/pf-attendance（P09）: apps/api（Java 21・Spring Boot・Maven）
- maeplego/pf-payroll（P16）: TypeScript（Hono・vitest）
- maeplego/portfolio-plan（読むだけ）: renovation/ の紙
  先に renovation/design/attendance-payroll/daicho.md（筋書きと道具の形）と renovation/kuchi.md（口と実測）を読む。renovation/naze.md（目的と範囲）と renovation/design/attendance-payroll/README.md（決まったこと）も。
- renovation/ は、枝 docs/eucalyptus のものを読む（master は遅れることがある）。clone が master だけを追う設定なら、git -C <portfolio-plan の道> ls-remote --heads origin で枝を見て、git -C <portfolio-plan の道> fetch origin docs/eucalyptus と名指しで取り、すぐに git -C <portfolio-plan の道> show FETCH_HEAD:renovation/<紙> で読む。

■ 目的
今の振る舞いを一字も変えずに、代表の筋書きを通したときの出力をそのまま記録し、hash を残す。
あとで器官をスイッチで入れるとき、スイッチが偽なら台帳が 0 行（一字も動かない）ことを示すために使う。

■ 守ること
1. 製品のふるまいを変えない。P09 の apps/api/src/main と、P16 の src/ のうち試験でないファイルは触らない。触らないと作れないときは、作る前に止まって、理由と一番小さい案を報告する。
2. 見つけた不具合は直さない。台帳に「今の姿」として残し、報告に書く（kikan.md の D1〜D9 と同じ書き方）。
3. 既存の試験は一つも変えない。試験の閾を緩めない。前提を足して通さない。
4. 台帳から外すものは、daicho.md の「台帳に入れないもの」の表だけ。ほかに外したくなったら、作る前に止まって問う。外したものは ledger/README.md に「何を・なぜ」と書く。
5. 走らせる環境を固定して、台帳に書く（ロケール en_US・UTF-8・LF・JDK と Node の版）。
6. 二度続けて走らせ、manifest が一字も変わらないことを確かめる。
7. 従業員は架空の種（DemoEmployees）だけ。秘密は書かない。
8. コミットは意図の単位で。本文に「なぜ」を書く。--no-verify・--amend・force・rebase は使わない。cd は使わず、git -C と絶対の道で。
9. 枝: pf-attendance も pf-payroll も ledger/first-pass。窓が別の名の枝を渡していても、この名で作る（作者の許し）。押せなかったら、そこで止めて報告する。master に直接書かない。
10. CI は、master への push と、手でだけ走る（決定 24。便 0002 で変えた形）。枝に押しても走らない。合流は作者の「はい」のあと（--no-ff）。合流の前に、枝で一度だけ手で走らせ、緑を確かめる（workflow_dispatch）。

■ 作るもの
P09（pf-attendance）
- 置き場所: リポジトリの直下に ledger/（台帳のファイル）。試験のコードは apps/api/src/test の下。
- 形: @SpringBootTest + MockMvc。時計は試験側で MutableClock に差し替える（PunchHttpTest の ClockConfig と同じ型）。
- 筋書き: daicho.md の S1・S2・S3。人数は 10 名（org-demo-a の全員）。
- 記録する出力: daicho.md の「S1 で読む出力」の表のとおり。日ごとの分・minutes-v1、ほかの出口（freee・MF・erp-generic-ja・受け渡し CSV・PDF の文字・未打刻）、拒否を含む全呼び出しの記録。画面の写しは入れない。
- 書き出し: UTF-8・LF でファイルに書く（標準出力は ASCII のことがある）。
- hash: 各ファイルに二本。生のバイトの sha256 と、正準形（行の並べ替え・JSON のキー順・id を除く）の sha256。manifest は sha256sum の形（道の順）で、生と正準形の二つを作る。二つの manifest の sha256 を LEDGER.sha256 に書く。
- 比べ方: コミットした台帳（golden）と、いま作った出力を照らす。一字でも違えば落ち、差分の行を出す。取り直しは -Dledger.update=true のときだけ。

P16（pf-payroll）
- 置き場所: リポジトリの直下に ledger/。
- 入力: P09 の S1 の minutes-v1 の写し。出どころ（P09 の commit・道・sha256）を ledger/input/SOURCE に書く。
- 筋書き: daicho.md の P1。
- 記録: 取り込みの応答（id を除く）・明細プレビュー・給与と会計の export の中身・受領（adapter と件数だけ）。
- hash: P09 と同じ形（生と正準形の二本）。
- 比べ方: vitest で golden と照らす。取り直しは LEDGER_UPDATE=1 のときだけ。
- 継ぎ目の照合: 手元用のスクリプトを置く。兄弟の ../pf-attendance の台帳のファイルと、ledger/input の写しの sha256 を照らす。npm test には入れない。

■ 問と答え（決定 33・決定 39）
- 問には番号を振らない。「問（番号はユーカリが振る）」と書き、選択肢 あ／い／う・見立て・答えの型「問（番号はユーカリ）：［ ］」を添える（O-17）。
- 先へ進めない問は、作者がこの窓で直に答えることがある。そのときは、その答えで進んでよい。
- ほかの問は、ユーカリが番号を振って作者に問い、答えはユーカリの便で届く。

■ 終わりの形（ここで止まって報告する）
- P09 の台帳ができたところで、一度返してよい（P16 は P09 の S1 の minutes-v1 を入力に使うので、先に P09 を照らせる）。
- 両方の試験が緑。P09: mvn -B -f <pf-attendance の道>/apps/api/pom.xml test。P16: npm --prefix <pf-payroll の道> test。既存の試験の数（P09 42 件・P16 12 件）が減っていない。
- 二度走らせて manifest が同じ。
- 報告に書くこと:
  - 0: 消した四本の枝と、消す前に確かめた先（ハッシュ）
  - 作ったファイル（file:line）とコミット
  - LEDGER.sha256 の値（P09・P16）
  - 外したものの一覧（daicho.md の表と同じか）
  - 台帳に出た「今の姿」のうち、daicho.md の「今の姿」と違ったもの（違ったら台帳が正。紙はユーカリが直す）
  - D1〜D9 が台帳のどの行に出たか
  - 製品コード（P09 の src/main・P16 の src/ の試験でないファイル）を触ったか（触っていないはず）
  - 自分の間違い（#N。オリーブの通し番号。O-9）
  - 迷ったこと
  - 問（番号は振らない。■ 問と答え のとおり）
- 報告は作者に渡す。ユーカリへは作者が貼る。

★ 決めるのは作者
```

## 手番 7 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| 頭の一行 | 「あなたは「pf-オリーブ」です。…」 | 「pf-オリーブへ。…」 | 役は二行で起こす（hajimeni.md） |
| 対象の道 | `portfolio-plan/renovation/attendance-payroll/` | `renovation/…` と、枝を名指しで取る一行 | 手番 3 の器・罠帳 W-12 |
| 置き場所 | 〔問 4 の答え〕 | 各リポジトリの直下に `ledger/` | 決定 13（直下はユーカリの設計） |
| 人数 | 〔問 2 の答え〕 | 10 名 | 決定 11 |
| 記録する出力 | 〔問 3 の答え〕 | daicho.md の表のとおり。画面の写しは入れない | 決定 12 |
| hash | 〔問 5 の答え〕 | 生と正準形の二本。manifest も二つ | 決定 14（manifest を二つにするのはユーカリの設計） |
| 継ぎ目の照合 | 〔問 4 が う のとき〕 | 条件を外した | 決定 13 |
| 途中で返す | — | P09 の台帳ができたところで、一度返してよい | ユーカリ（P16 の入力は P09 の出力。バンブー便の「途中で返してよい」と同じ考え） |
| 〔枝〕 | 〔枝〕 | 〔枝〕のまま | 問 17 |

## 手番 8 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| 守ること 9（枝） | 〔枝〕 | 両方とも ledger/first-pass。窓が別の枝を渡していても、この名で作る。押せなかったら止めて報告する | 決定 20（問 17 → あ）と、問 17 の注 |
| 報告に書くこと | — | 自分の間違い（#N。オリーブの通し番号） | 問 18 の見立て あ（決定 22 で、そのまま決まった） |

## 手番 10 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| 守ること 10（CI） | — | CI は master と手でだけ走る。合流の前に、枝で一度だけ手で走らせる | 決定 24 |

## 手番 18 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| ■ 問と答え | — | 問に番号を振らない。先へ進めない問は作者が直に答えることがある。ほかの答えはユーカリの便で届く | 決定 33・決定 39（問 31 の「便 0001 で伝える」） |
| 報告に書くこと | — | 問（番号は振らない） | 決定 33（便 0003 と同じ形） |
| 状態・渡す条件 | 便 0002 が master に入ったあと | 便 0002・0003 が master に入り、枝を切り替えたあと。読む一行は docs/eucalyptus に直す | 決定 35・37（渡す順はユーカリ） |

## 手番 25 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| 対象（renovation/ を読む枝） | claude/dazzling-franklin-c45tgk | docs/eucalyptus | 決定 35・37（枝の切り替えの段取りの 2） |

## 手番 26 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| ■ 0（新しい節） | — | 合流が済んだ四本の枝を、祖先かを確かめてから一本ずつ消す。これからの作業の枝も、合流して master が緑なら消す | 決定 46（問 36 → あ） |
| 報告に書くこと | — | 0: 消した四本の枝と、消す前に確かめた先 | 決定 46 |

## 手番 28 で変えたこと

| どこ | 前 | 今 | もと |
| --- | --- | --- | --- |
| 状態 | 便 0002・0003 が master に入り、枝を切り替えてから渡す | 渡す条件がそろった | 決定 44・47 |
| 対象（renovation/ を読む一行） | `git ls-remote …`・`git fetch …` | `git -C <portfolio-plan の道> …`。取ったら、すぐに FETCH_HEAD で読む | 罠帳 W-29・W-30。hajimeni.md の「読む場所」の一行と同じ形 |
| 終わりの形（試験の命令） | `mvn -B -f apps/api/pom.xml test`・`npm test` | `mvn -B -f <pf-attendance の道>/apps/api/pom.xml test`・`npm --prefix <pf-payroll の道> test` | 罠帳 W-29（#24）。この形で P09 は 42 件・P16 は 12 件、どちらも失敗 0【測】（手番 28。master の 938e128・fdf434b） |
