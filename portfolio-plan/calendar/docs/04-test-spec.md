# P05 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P05 calendar |
| 対象スライス | 1–7。自動化は `npm test`（slot-engine 13 + api 24 + worker 3） |
| 最終更新 | 2026-08-18 |
| 矛盾時の正 | 製品リポジトリの vitest。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| slot-engine | DB なし単体。`now` と range を固定 | TZ / DST / バッファ / min notice |
| HTTP | Hono `app.request` + `MemoryStore` + 固定 Clock | 認可、公開契約、再検証、同時 book |
| Postgres exclusion | Compose 手動または未自動化 | gist が 23P01 を返すことの確認 |

メモリの同時 book は「Store 第 2 段 + イベントループ」を検証する。Postgres の真の並列 INSERT とは同じ期待結果（201 と 409）だが、ロック実装は別物。CI がメモリだけでも要件 FR-09 の回帰は拾える。本番同等の排他は手動デモか将来の integration テスト。

exploit / PoC は書かない。不正 Instant の book は 409 を期待する正規テストに留める。

## 2. エンジン（`packages/slot-engine`）

共通フィクスチャの例: ホスト `Asia/Tokyo`、平日 09:00–12:00、30 分、バッファ 0、min notice 0。期待 Instant はホスト壁時計から変換した値と比較する。

| ID | 観点 | 入力の要点 | 期待 |
| --- | --- | --- | --- |
| TS-E01 | 東京平日 | 2026-03-02（月）1 日 | 09:00–11:30 の 6 Instant |
| TS-E02 | 週末 | 土曜を含む range、平日ルールのみ | 土日の開始が無い |
| TS-E03 | ゲスト TZ は計算外 | 同じ Instant を LA 壁時計で読めること | 集合はホスト基準のまま。LA 9:00 で増えない |
| TS-E04 | DST 春進み | LA、存在しない 2:00 付近 | 欠けた時間の開始を出さない |
| TS-E05 | DST 対照（通常日） | LA 01:00–04:00 窓 | 30 分枠が 6 本 |
| TS-E06 | DST 秋戻り | 重複する 1:00 相当 | Instant が一意。重複カウントしない |
| TS-E07 | バッファ | 既存予約の前後 15 分 | バッファに少しでも重なる候補が落ちる |
| TS-E08 | min notice | now と最短分 | `now+notice` より前の開始が無い |
| TS-E09 | 既存予約・バッファ 0 | 1 枠だけ衝突 | その枠だけ落ち、隣接は残る |
| TS-E10 | 例外日 | blocked のホスト暦日 | その日は 0 件 |
| TS-E11 | range 上限超過 | 14×24h より長い | `RangeTooLongError` |
| TS-E12 | range ちょうど 14×24h | 上限ちょうど | 受理（空でもよい、エラーにしない） |
| TS-E13 | 逆転 range | end ≤ start | `InvalidSlotInputError` |

## 3. ホスト API

Clock はテストで東京 2026-03-01 00:00 などに固定する。

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-H01 | 作成と一覧 | 201。同じホストの一覧に 1 件。他ホストの GET は 404 |
| TS-H02 | 保存ルールで枠計算 | 東京月曜 6 Instant。engine と同じ |
| TS-H03 | 例外日 | ブロック日の `starts` が `[]` |
| TS-H04 | ルール置換 | 月曜 14:00–15:00 なら 14:00 と 14:30 のみ |
| TS-H05 | range 14 日超 | 400 |
| TS-H06 | slug 重複（他ホスト含む） | 2 件目 409 |
| TS-H07 | ホストヘッダなし | 401 |
| TS-H08 | `/health` `/ready` | ヘッダなしで 200（メモリ ping） |

## 4. 公開予約

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-B01 | 公開 slots | 認証なし 200。`starts` はホスト計算。JSON に `@` も guestName も無い | FR-12 |
| TS-B02 | 予約後に枠が消える | 201、`cancelToken` が十分長い。再 GET でその Instant が無い。ホスト一覧に 1 件 | FR-07 |
| TS-B03 | 同時 2 book | `Promise.all` で同一 slot、別メール・別冪等キー。ステータス集合が `{201,409}`。409 の code は `slot_unavailable`。失敗 JSON に `@` が無い | FR-09 |
| TS-B04 | 捏造 Instant | 東京 8:00（ルール外）を POST | 409。INSERT しない | FR-04 |
| TS-B05 | 冪等再送 | 同じキー・同じ本文の 2 回目は 200。`cancelToken` 無し（再発行しない） | FR-10 |
| TS-B06 | キャンセル | 201 の `cancelToken` で cancel → 200 `cancelled`。再 GET slots に Instant が戻る | |
| TS-B07 | 不正 cancel トークン | 404。JSON に `@` なし | |
| TS-B08 | ICS | cancelToken クエリで 200 `text/calendar`、`BEGIN:VCALENDAR` | |

## 4.1 内部 API

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-I01 | externalRef 冪等 | 同一 host + ref の 2 回目 200、slug は初回のまま |
| TS-I02 | ホスト別一覧 | `GET .../hosts/:sub/event-types` で 1 件 |
| TS-I03 | 予約詳細 | public book 後 `GET .../bookings/:id` で event slug + guestEmail |
| TS-I04 | 不正 Bearer | 401 |

## 5. ワーカー

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-W01 | 24h 窓 | 開始 24h 前後の予約だけ 24h 種別 |
| TS-W02 | 1h 窓 | 開始 1h 前後の予約だけ 1h 種別 |
| TS-W03 | 送信済みスキップ | `reminder_sent` ありなら再送しない |

## 6. 未自動化（既知）

| ID | 観点 | いまの確認方法 |
| --- | --- | --- |
| TS-M01 | Postgres gist が 23P01 を返す | Compose 起動後、同じ枠を並列 curl。将来 Testcontainers 可 |
| TS-M02 | ゲスト TZ 切替 UI | `/book/:slug` 手動。API では `starts` が TZ クエリを持たないことで代替 |
| TS-M03 | キャンセル画面 | `/cancel?token=` 手動。API は TS-B06 |
| TS-M04 | 2 タブ手動デモ | UI 後。API では TS-B03 |
| TS-M05 | Mailhog でリマインド本文 | Compose 手動 |

失敗したテストを skip して緑にしない。Postgres が無い環境で TS-M01 を skip する場合は、未実施と README に書く。

## 6. トレース可能性

| 要件 | テスト |
| --- | --- |
| FR-01 | TS-H01, TS-H07 |
| FR-02, FR-05 | TS-E01, TS-E03, TS-H02 |
| FR-03 | TS-E10, TS-H03 |
| FR-04 | TS-B04 |
| FR-06 | TS-E07, TS-E08, TS-E09 |
| FR-07 | TS-B01, TS-B02 |
| FR-08, FR-09 | TS-B03（メモリ）。TS-M01（Postgres） |
| FR-10, FR-11 | TS-B05, TS-B02 |
| FR-12 | TS-B01, TS-B03 |
| NFR-01 | TS-E04–E06 |
| NFR-02 | TS-E11, TS-H05 |
