# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | personal-finance（GitHub: [pf-finance](https://github.com/maeplego/pf-finance)） |
| 最終更新 | 2026-08-20 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

## 1. ユーザーから見た振る舞い

起動後、Web は開発ユーザー `demo` として API を呼ぶ。2026-06〜08 の架空取引と月次予算 200000 円が入っている。

- `/` : 選択月のサマリー、予算バー、入力フォーム、取引一覧、削除、**CSV の書き出しと取り込み**
- `/reports` : 同じ月のカテゴリ円グラフと日次棒グラフ
- ユーザー欄を `other` にすると空の家計（デフォルトカテゴリのみ）。`demo` の行は出ない

金額欄は数字のみ。`12.5` や `1e2` はクライアントでも API でも拒否する。CSV も整数円。カテゴリは名前と kind で突合する。

Chrome（localhost）ではインストール可能。オフラインの新規入力と削除は IndexedDB キューに残り、オンライン復帰で `POST /v1/sync` する。同じ id は `updatedAt` の新しい方が残る。削除は tombstone（一覧と GET からは見えない）。

## 2. 金額

保存値は常に正の `amountYen`（整数）と `kind`（`expense` \| `income`）。合計の符号付き円はレポート計算時だけ作る。表示は `¥280,000` のように小数部を付けない。

## 3. 月と日付

- 取引日: `YYYY-MM-DD`。存在しない日付は 400
- 月: `YYYY-MM`。その月の `occurred_on` だけが一覧・レポート・CSV に入る
- タイムゾーン: 日付は暦日。時刻は監査用 `timestamptz`（UTC）

## 4. エラー

```json
{ "error": { "code": "validation_error", "message": "amount must be a safe integer yen" } }
```

| 状況 | HTTP | code |
| --- | --- | --- |
| 開発ヘッダなし | 401 | unauthorized |
| 小数円・0・負 | 400 | validation_error |
| 他人の ID | 404 | not_found |
| store 不通 | 503 | not_ready（`/ready`） |

## 5. 削除と CSV

DELETE と sync の削除は tombstone（`deletedAt`）。一覧・GET・レポート・CSV には出ない。同じ id に新しい `updatedAt` と `deletedAt: null` を送ると復活する。エクスポートは自分のその月の生きている行だけ。取り込みは別ユーザーへコピーしても元の id は漏らさない。

## 6. シード

`demo` かつ取引 0 件のときだけ投入。店名・人名は架空。銀行出力のコピーではない。
