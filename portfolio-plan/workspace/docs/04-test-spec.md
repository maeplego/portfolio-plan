# P04 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P04 workspace |
| 対象スライス | 1–7 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `apps/api` の `go test` と `apps/collab` の `npm test`。未自動化は本表の「手動」 |

実行: `pf-workspace/apps/api` で `go test ./...`。collab 部屋名は `apps/collab` で `npm test`。IME diff は `apps/web` で `npm test`。

## 自動化済み

| ID | 観点 | 手順の要約 | 期待 |
| --- | --- | --- | --- |
| TS-H01 | ヘルス | `GET /health` | 200 |
| TS-W01 | 作成 | `POST /v1/workspaces` name=Demo Team, sub=owner-1 | 201、id あり |
| TS-K01 | 既定列 | ボード作成 | 201、columns が 3 |
| TS-K02 | カード作成 | 先頭列へ POST card | 201 |
| TS-K03 | 移動 | 2 列目へ PATCH move（version 一致） | 200 |
| TS-K04 | 楽観ロック | 同じカードを古い version で再移動 | 409 |
| TS-A01 | 非所属 | 未知 sub でボード GET | 403 |
| TS-A02 | guest 書き込み | owner が guest を追加し、guest が move | 403 |
| TS-P01 | ツリー | 公開ルート + 子 + draft | guest tree はルート 1 件と子 1 件。draft なし |
| TS-P02 | 下書き秘匿 | guest が draft GET | 404 |
| TS-P03 | guest PATCH | 公開ページを guest が更新 | 403 |
| TS-P04 | 楽観ロック | 古い version で PATCH | 409 |
| TS-P05 | 循環 | parentId を自分にする | 400 |
| TS-T01 | 純関数 | `BuildPageTree` / `FilterGuestPages` | 順序と draft 祖先の除外 |
| TS-C01 | 部屋名 | `ValidCollabRoom` / collab `validRoom` | パス拒否、ULID 許可 |
| TS-C02 | チケット | owner が published の collabDocumentId で POST ticket | 201、readOnly false |
| TS-C03 | guest 公開 | guest が同じページの ticket | 201、readOnly true |
| TS-C04 | guest 下書き | guest が draft の ticket | 404 |
| TS-C05 | 内部無トークン | `/internal/v1/collab/authorize` に Bearer なし | 401 |
| TS-C06 | 部屋不一致 | 別 collabDocumentId を documentName に指定 | 403 |
| TS-C07 | ドキュメント | member が POST document。guest が GET 一覧と POST | 作成 201。guest 一覧 200、作成 403 |
| TS-C08 | スナップショット | internal plaintext → snapshot → GET page.body | 本文が差し替わる |
| TS-H02 | IME diff | `diffEnds` / `shouldSyncToYjs` | 変換中は同期しない。確定は中間だけ置換 |
| TS-M01 | 既定チャンネル | ワークスペース作成 | `general` が 1 件 |
| TS-M02 | seq | 2 通投稿 | seq 1 と 2 |
| TS-M03 | afterSeq | `?afterSeq=1` | 2 通目だけ |
| TS-M04 | guest | guest POST / GET / ticket | 投稿 403、履歴 200、ticket readOnly |
| TS-S01 | 検索 ACL | draft に pineapple、guest が q=pineapple | owner は draft ヒット。guest は draft / draft 配下なし。カード・メッセージはヒット |
| TS-S02 | 空 q / 非所属 | q 空、未知 sub | 400 と 403 |
| TS-N01 | メンション | `@demo-user-b` と `@not-a-member` | mentions はメンバー 1 件 |
| TS-F01 | 添付 | member が wiki/chat 画像。guest upload / page attach | 201 と 403。content?t= は 200、偽トークン 401 |
| TS-F02 | サイズ | SaveLocalFile が MaxUploadBytes+1 | ErrTooLarge |
| TS-SP01 | スプリント ACL | guest が POST sprint。guest が burndown GET | 403 と 200 |
| TS-SP02 | バーンダウン | 2 カードを割り当て、1 枚を Done | 当日 remaining が 1。単位 cards |
| TS-V01 | 版 | 公開ページ作成後に body PATCH | 版 2 件。list に body なし |
| TS-V02 | diff / restore | from=1 to=2、guest restore、owner restore | insert 行あり。guest 403。owner 本文が v1 |
| TS-V03 | guest draft | draft の versions GET | 404 |
| TS-D01 | 行 diff | `a\nb\nc` vs `a\nx\nc` | equal/delete/insert/equal |
| TS-PG01 | Postgres | `WORKSPACE_DATABASE_URL` があるとき store 結合 | ULID、カード移動の 409、chat seq |

## 未自動化（受け入れの手動）

| ID | 観点 | 手順 | 期待 |
| --- | --- | --- | --- |
| TS-U01 | 開発 Web | Compose または `next dev` + API。`/` で WS とボードを作る | 3006 で一覧に出る |
| TS-U02 | DnD | カードを In Progress へドラッグ | 列が変わり、リロード後も残る（同一プロセス） |
| TS-U03 | ユーザー切替 | A で作った WS を `?user=demo-user-b` で開く | B の一覧に出ない |
| TS-U04 | OIDC | 未設定の単体デモ | `/login` に飛ばない |
| TS-U05 | Wiki | `/` から Wiki、ページ作成、Markdown プレビュー | 見出しが出る。guest 切替で draft が見えない |
| TS-U06 | 2 ウィンドウ | README の手順で A と B が同じ Docs を開く | 文字とカーソルが相手に見える |
| TS-U07 | フォールバック | collab を止めて Wiki を開く | 数秒後に textarea 保存ができる |
| TS-U08 | チャット | A/B で `#general` を開き投稿 | 相手に本文が出る。入力中表示 |
| TS-U09 | IME | Wiki collab で「日本語」を変換確定 | 変換中にキャレットが飛ばない |
| TS-U10 | 検索 | ホームから q を送り guest 切替 | draft が guest 結果に出ない |
| TS-U11 | 添付 | Wiki / Chat に画像 1 枚 | プレビューに出る。guest フォームなし |
| TS-U12 | バーンダウン | ボードからスプリント画面。カードを Done | チャートと表の残りが減る |
| TS-U13 | Wiki diff | 本文を保存して比較、復元 | 行 diff が出る。復元後に v1 本文 |
