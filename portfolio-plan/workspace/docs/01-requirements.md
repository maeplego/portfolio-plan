# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | ワークスペース [pf-workspace](https://github.com/maeplego/pf-workspace) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

小さな開発チームは課題・文書・会話を別ツールに散らすと、招待と権限が何度も生まれ、どれが正本か分からなくなる。ワークスペースは共通の場所とロールの上に、ボード / Wiki / チャット / 共同編集を載せる。Linear + Notion + Slack の学習用ミニ実装であり、各商用製品の置き換えではない。

## 2. 含む

- 認証された主体（OIDC `sub` または開発ヘッダ）がワークスペースを作れる。作成者は owner
- owner は member / guest を追加できる。所属ワークスペースだけが見える
- ボードは既定 3 列（To Do / In Progress / Done）。member 以上がカード作成・更新・列間移動。guest は閲覧のみ（サーバー強制）
- ページは親子と並び順のツリー。`draft` / `published`。guest は published のみ（下書きの存在は 404）
- collab 稼働時は CRDT が Wiki 本文と独立ドキュメントの正。未接続時は API PATCH にフォールバック
- 2 ブラウザで同じ部屋を同時編集できる。部屋名は ULID。チケットと不一致なら拒否
- 横断検索（メモリ上の大小無視部分一致）。guest は draft とその配下を出さない
- チャット履歴 REST と別 WebSocket。`@sub` はメンバーに解決できたものだけ `mentions`
- スプリント（name, startAt, endAt UTC）とカード割り当て。バーンダウンは未完了カード数/日
- Wiki の title+body 履歴（一覧・取得・行 diff・復元）
- Compose の Postgres にカンバン・Wiki・チャット履歴を永続化する

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| Postgres FTS / tsvector | 検索はメモリ部分一致 |
| 本番 OIDC 必須 | 単体デモは `WORKSPACE_DEV_AUTH`。overlay `b-collab` の web は OIDC 必須 |
| ストーリーポイント必須化 | バーンダウンはカード数 |
| カンバンのリアルタイム同期（他ブラウザ即反映） | DnD + 再取得。WS はチャットと混ぜない |
| GitHub 双方向同期 | 開発者基盤と混ぜない |
| 音声・ビデオ、E2EE | 範囲外 |
| 予約カレンダーからの面談枠取得 | 範囲外 |
| メンションのメール / Push / 未読バッジ | 未実装 |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| owner | ワークスペース作成者。メンバー追加可 | 開発中は `X-Dev-User-Sub`。連携時は認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| member | ボードを編集できる所属者 | 同上 |
| guest | 閲覧のみ。カード移動禁止 | owner が追加 |
| システム（API / collab） | 権限と本文同期の正 | — |

## 5. 前提

- ID は ULID。外部に連番を出さない
- 時刻は UTC（JSON は RFC3339）
- 単体デモは Compose。他製品無しで Web + API + collab が動く
- API 再起動後も Compose / overlay の Postgres にカンバン・Wiki・チャット履歴は残る。Y.Doc は collab 再起動で消える
- 添付は fileId。メディア基盤 [pf-media](https://github.com/maeplego/pf-media) 未設定時はローカル保存（20MB を超えない）

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 認証済みユーザーはワークスペースを作成でき、作成者は owner になる | 空の作業場所を他人名義で作らせない |
| FR-02 | 所属していないワークスペースは一覧にも詳細にも出ない | 横断テナント漏洩 |
| FR-03 | owner だけが member / guest を追加できる。owner ロールの付与はしない | 権限エスカレーション |
| FR-04 | 未認証の `/v1/*` は 401 | UI 非表示は認可ではない |
| FR-05 | ボード作成時に To Do / In Progress / Done が存在する | 画面デモを空ボードにしない |
| FR-06 | member 以上はカードを列に追加し、タイトル・説明を更新できる | カンバンの本体 |
| FR-07 | カード移動は `version` が一致したときだけ成功する。不一致は 409 | 2 人が同時に動かしたときの壊れ方 |
| FR-08 | guest のカード移動・更新は 403。一覧・ボード参照は 200 | ロールをサーバーで強制する |
| FR-09 | ページの親子は API が正。1 レスポンスのツリーで返す | N+1 と Yjs にツリーを持たせない |
| FR-10 | member 以上が title / Markdown body / status を更新できる | collab 未接続時のフォールバック |
| FR-11 | guest のツリーと GET から draft と、draft 配下の published を出さない | 下書き漏洩 |
| FR-12 | ページ更新も `version` 一致が必要。親を自分や子孫にすると 400 | ループしたツリーを作らせない |
| FR-13 | Wiki 本文と独立ドキュメントの同時編集は CRDT（Yjs）。カンバン移動には使わない | プロトコルを混ぜない |
| FR-14 | collab 接続は短命チケット。部屋名は ULID。チケットの文書 ID と不一致なら拒否 | 推測・パストラバーサル |
| FR-15 | guest の collab は read-only。draft Wiki のチケットは出さない（404） | ロールを WS でも強制する |
| FR-16 | 独立ドキュメントは member 以上が作成。guest は一覧・参照のみ | 共有閲覧 |
| FR-17 | メッセージは store に書いてから WS で配る。seq はチャンネル内単調増加 | WS だけの記憶だと再接続で欠ける |
| FR-18 | 再接続は `afterSeq` で差分を取る | 機内モード解除 |
| FR-19 | guest の投稿は 403。履歴 GET は 200。typing は永続化しない | ロール強制 |
| FR-20 | 横断検索は所属者のみ。空 q は 400。guest は draft / draft 配下をヒットさせない | UI 非表示は認可ではない |
| FR-21 | 投稿本文の `@sub` はメンバーに解決できたものだけ `mentions` に入り、WS `type=message` にも載る | 別ソケットを増やさない |
| FR-22 | 添付は fileId のみ。guest は追加 403。メディア未設定時はローカル保存 | 単体 Compose は media なしで動く |
| FR-23 | ボードにスプリントを作れる。member+ 書き込み、guest 読み取り | ロールはサーバー強制 |
| FR-24 | カードをスプリントに割り当てられる。バーンダウンは期間内の日ごとの未完了カード数（Done 列以外） | ポイントは持たない |
| FR-25 | Wiki は title+body の API スナップショット版を列挙・取得・行 diff できる | Y.Doc バイトは履歴にしない |
| FR-26 | 版への復元は lock version 付きで本文を戻し新しい版を足す。guest の draft 履歴は 404 | 存在漏洩を検索・GET と同じ規則にする |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | カンバンの競合に CRDT を使わない | 列移動は全順序が要る |
| NFR-02 | README に学習用である旨を書く | 本番誤用 |
| NFR-03 | 単体 Compose で Web + API + collab が起動する | 単独起動 |
| NFR-04 | 秘密をログに出さない | 共通規約 |
| NFR-05 | Markdown プレビューは raw HTML を出さず、`javascript:` リンクを無効化する | XSS。サニタイズは表示側 |
| NFR-06 | 本文は 100000 文字まで。Y.Doc 更新は 512KiB まで | 巨大ペースト |
| NFR-07 | collab は API と別プロセス。チャットは API 上の `/chat/ws`（Yjs と混ぜない） | 3 種のリアルタイムを単一ソケットにしない |
| NFR-08 | IME 変換中は Y.Text に中間キーを送らない | 確定前の文字でキャレットが飛ぶのを防ぐ |

## 8. 受け入れ

1. owner がワークスペースとボードを作り、3 列がある
2. owner がカードを作り、別列へ `version` 付きで移動できる。古い `version` は 409
3. 非メンバーのボード GET が 403。guest のカード移動が 403
4. 開発モードの Web でボードを開き、カードを DnD できる
5. owner が公開ページと子ページを作り、guest の tree に draft が出ない。guest の draft GET は 404、PATCH は 403
6. 古い version のページ PATCH が 409。自分を親にする PATCH が 400
7. owner が collab チケットを取れ、guest は published で read-only、draft は 404
8. チケットと別の部屋名での内部認可が 403。パス風の部屋名は 400
9. 2 ウィンドウで同じ Docs / Wiki 本文を編集できる
10. owner が general に投稿し seq が 1, 2。`afterSeq=1` で 2 だけ返る。guest の投稿は 403、履歴 GET は 200
11. owner の検索が draft に当たり、guest の同じクエリは当たらない。非メンバー 403。空 q 400
12. `@member` 投稿の `mentions` にその sub があり、未知の `@nobody` は入らない
13. member が画像をローカル添付でき、guest の upload / page attach は 403
14. member がスプリントを作りカードを割り当て、Done へ移すと当日の remaining が減る。guest の作成は 403、バーンダウン GET は 200
15. 公開ページの 2 版を diff でき、guest は published の履歴を読め、draft 履歴は 404。guest の restore は 403
16. Compose 再起動後もボードと Wiki が Postgres から戻る
