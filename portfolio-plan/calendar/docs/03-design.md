# P05 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P05 calendar |
| 対象スライス | 1–3 の実装。4–7 は構成上の予定のみ |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

要件の「何を守るか」に対し、モジュールと永続化で「どう守るか」。スタック選定の短文は `DESIGN.md`。

## 1. 全体構成

```
pf-calendar/
  packages/slot-engine   純関数。ホスト TZ の壁時計 → Instant[]
  apps/api               Hono。HTTP、認可、再検証、永続化
  apps/web               未実装。枠計算も book も置かない
  apps/worker            未実装
  deploy/                Postgres + API
```

予約確定の正は `apps/api`。slot-engine は「この条件ならどの Instant がオファーか」だけを返す。UI が同じ関数を表示用に呼んでも、INSERT してよい根拠にはしない。

Store はインタフェース。`MemoryStore`（テスト・DB なし起動）と `PostgresStore`（Compose）が同じ契約を実装する。

## 2. 時刻の内部モデル

| 層 | 型 | 役割 |
| --- | --- | --- |
| ルール | `dayOfWeek` + `startLocal`/`endLocal` + `hostTimeZone` | 正本の意図 |
| 例外 | ホスト現地 `PlainDate` | その暦日を生成対象から外す |
| engine 入出力 | `Temporal.Instant` | 比較可能な一点 |
| HTTP | Instant の ISO 文字列 | 言語非依存の契約 |
| DB | `timestamptz` + 生成列 `tstzrange` | 重なり判定 |
| `now` | `Clock.nowIso()` | min notice。テストで固定 |

ホスト現地の暦日への変換は `Instant.toZonedDateTimeISO(hostTimeZone).toPlainDate()`。UTC 日付で切ると東京と LA で「何日の予約か」がずれる。

`disambiguate: "compatible"` で存在しない DST 壁時計をエンジンが落とす／重複時間を一意の Instant にする。`Date` と数値オフセットの手計算はしない。

サーバー OS の TZ に 9:00 を解釈させない。コンテナは UTC 前提で、IANA 名はデータとして持つ。

## 3. 予約確定の二段構え（三段ではない）

責務が違う防御を **2 段**重ねる。Memory と Postgres は同じ第 2 段の別実装である。

| 段 | どこ | 見るもの | 同時 2 リクエストに強いか |
| --- | --- | --- | --- |
| 1. ドメイン | `isOfferedStart` | ルール、例外、バッファ、min notice、**読み取り時点**の確定予約 | 弱い（TOCTOU） |
| 2. 永続化 | `Store.createBooking` | 確定予約同士が重ならないこと | 実装次第。Postgres は強い |

第 1 段が必要な理由: exclusion は「時間帯が重ならない」しか見ない。ホストが公開していない 8:00 や、min notice 未満、バッファ抵触は DB 制約だけでは分からない。クライアントが Instant を捏造できる。

第 2 段が必要な理由: 第 1 段は「さっき読んだ一覧」に対する判定であり、INSERT までの間に別リクエストが確定できる。

### 3.1 TOCTOU とは

Time Of Check to Time Of Use。**確認した時点では真だった条件が、それを使って書き込む時点では偽になっている**こと。

本 API では:

- **Check:** `listConfirmedBookings` のスナップショットで `isOfferedStart` → true
- **Use:** `createBooking` の INSERT
- **隙:** Check と Use のあいだに、別ハンドラが同じ枠を確定できる

セキュリティの「権限を見てからファイルを開く」古典と同じ構造。予約では権限ではなく「空いている」が競合する。

### 3.2 同時 2 リクエストの時系列

前提: 枠 `S`（東京 2026-03-02 09:00 = Instant `2026-03-02T00:00:00Z`）はオファー中。確定予約は 0 件。ゲスト A・B が別メール・別冪等キーで同じ `slotStart` を POST する。

```
T0  DB / メモリ配列に confirmed は無い。

T1  A と B の POST /public/:slug/book がほぼ同時に入る。

T2  両者 getEventTypeBySlug → 同じルール。

T3  両者 listConfirmedBookings → どちらも [] 。
    ★ Check 用スナップショット。ここまで両者の世界は「空いている」。

T4  両者 isOfferedStart(ルール, [], S, now) → どちらも true。
    ★ Time Of Check。アプリ第 1 段だけでは両方通る。
    改ざん 8:00 ならここで false（競合以前に仕様違反）。

T5  両者 newCancelToken（平文は応答用。ハッシュだけ後で保存）。

T6  両者 createBooking に入る。★ Time Of Use（永続化）。
```

**本番（PostgresStore）**

```
T6a  A の INSERT が先に成功。exclusion 用の gist が (event_type_id, during) を確保。
T6b  B の INSERT が during && で衝突 → SQLSTATE 23P01。
T6c  API は 23P01 を ConflictError("slot unavailable") → HTTP 409。
T7  外部: 201 と 409。confirmed は 1 行。
```

Postgres は INSERT 文の評価と制約をストレージのロック下で行う。アプリが Check で両方 true でも、Use で片方だけ残る。これが「DB が最後の砦」。

**テスト（MemoryStore）**

`overlapsConfirmed` のあと `push` まで **await が無い。** Node は 1 スレッドなので、A の `createBooking` が push まで走り切ってから B が `overlapsConfirmed` を見る。結果は同じく 201 と 409。

これは DB の排他と同じ**契約**（Store が重なりを拒否する）をメモリで真似ている。本番パスに MemoryStore は乗らない。

もし MemoryStore から `overlapsConfirmed` を外すと、第 1 段を両方通過した A と B がどちらも `push` し、**二重予約になる。** イベントループは Check（isOfferedStart）と Use（push）の間で相手を走らせる。だからメモリ実装にも第 2 段が要る。

### 3.3 なぜ三段構えではないか

見かけ上のチェックは次の 3 つに見える。

1. `isOfferedStart`
2. `MemoryStore.overlapsConfirmed`
3. Postgres `EXCLUDE USING gist`

しかし 2 と 3 は **同時に直列で動かない。** `createApp({ store })` はどちらか一方。役割はどちらも「確定予約を重ならせて書き込まない」。

| 誤解 | 実際 |
| --- | --- |
| アプリ・メモリ・DB の三重 | アプリ（ドメイン）+ Store（永続化）の二重 |
| メモリが本番の追加ガード | テスト／DB なし起動の代替実装 |
| DB があれば isOfferedStart は不要 | DB は重なりしか見ない。8:00 捏造や min notice は見ない |

冪等キーの `UNIQUE (event_type_id, idempotency_key)` は別問題（再試行）。ダブルブッキング防止ではない。同じ人が同じキーで二度送ったときに行を増やさない。

### 3.4 book がホスト現地の「その日」を再計算する理由

`isOfferedStart` は `slotStart` をホスト TZ の暦日に落とし、その日の 00:00–翌 00:00（Instant 窓）で engine をフル実行し、返った Instant に完全一致するか見る。

一覧 GET の range はゲストの「見たい週」であり、book の正しさの根拠にしない。バッファ判定には同日の他予約が必要なので、1 Instant だけルール照合せずその日を再生成する。

## 4. データ

ホスト → イベントタイプ 1:N。ルール・例外・予約はイベントタイプに従属。

`bookings.during` は `tstzrange(start_at, end_at, '[)')` の生成列。半開で隣接枠（9:00–9:30 と 9:30–10:00）は重ならない。exclusion は `status = 'confirmed'` のみ。キャンセル状態を足すときは、確定だけが排他に残るようにする。

キャンセルトークンは sha256 ハッシュを保存。平文は 201 のときだけ。ログ禁止。

## 5. モジュール境界

| 場所 | やってよい | やってはいけない |
| --- | --- | --- |
| slot-engine | 純関数、TZ/DST | HTTP、DB、`Date.now()` 直読み |
| `slots.ts` | engine へのアダプタ、host 暦日窓 | 認可 |
| `app.ts` | バリデーション、再検証してから store | Instant を検証なし INSERT |
| Store | 永続化と重なり/一意の最後の拒否 | ホスト壁時計の解釈 |

## 6. セキュリティ設計（現状）

- 公開 API は認証なし。返すフィールドを最小にする
- ホスト資源はサーバー側で host id を照合。UI の非表示を認可にしない
- 409 本文に他ゲスト PII を出さない（同時失敗側にもメールを返さない）
- OIDC 未接続。`CALENDAR_DEV_AUTH` が本番相当ではない

## 7. デプロイ（現状）

Compose: API `:8095`、Postgres `:5434`。`CALENDAR_DATABASE_URL` が空ならメモリ（複数プロセスで共有されない。デモに使わない）。

## 8. 後続スライスで増える内部要素

| スライス | 設計インパクト |
| --- | --- |
| 4 Web + OIDC | book は Route Handler に移さない。BFF は API を呼ぶだけ |
| 5 cancel | トークン照合はハッシュ比較。status 変更後は exclusion 対象外 |
| 6 worker | `start_at`（UTC）とサーバー now でリマインド。ゲスト TZ は本文用 |
| 7 P10 | 同じ Instant 契約。ホストは企業ユーザーの `sub` |
