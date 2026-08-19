# テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | コンテンツ基盤（GitHub: `pf-content-blog`、`pf-content-shortener`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | 製品リポジトリのテストを優先する。本表と違うときはテストか本表のどちらかを直す |

自動化は shortener の `go test ./...` と blog の `npm test`。

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| target / code | DB なし | scheme、allowlist、連番に見えないこと |
| link service | メモリ Store | 作成、期限、他人 403、非同期クリック |
| HTTP | httptest | 401、302、400 |
| visibility / slug | node:test | 下書き非公開、予約 slug |

exploit / PoC は書かない。実在 PII を fixture に置かない。

## 2. 短縮

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-S01 | `javascript:` | 作成エラー |
| TS-S02 | 許可外ホスト | `host_not_allowed` |
| TS-S03 | localhost 記事 URL | 作成成功。code 長 7 |
| TS-S04 | 連続 2 件 | code が一致しない |
| TS-S05 | 数字のみ slug | 拒否 |
| TS-S06 | 期限切れ Resolve | inactive |
| TS-S07 | 他人の stats | forbidden |
| TS-S08 | httptest 302 | Location が元 URL。401 はヘッダなし作成 |
| TS-S09 | 非同期クリック | 2s 以内に count>=1。日次行が増えてよい |

## 3. ブログ

| ID | 観点 | 期待 |
| --- | --- | --- |
| TS-B01 | draft は isPublic false | 公開に出ない |
| TS-B02 | published + publishedAt<=now | true |
| TS-B03 | 未来の publishedAt | まだ false |
| TS-B04 | slug `admin` | 拒否 |
| TS-B05 | 下書き公開 URL | 画面 404（Compose で確認） |
| TS-B06 | Draft Mode と編集者 | 両方そろったときだけ下書き可。cookie または Draft Mode 片方では不可 |

## 4. 未自動化

- OG 画像のピクセル（契約は公開題名のみ。Compose で確認）
- Compose 実機の管理 Publish、短縮ボタン、日次グラフの見た目（契約は stats JSON + 手動 `/demo`）
- Redis 障害時の DB フォールバック
- Postgres unique 衝突の integration タグ
- Lighthouse（数値を盛らない。未計測）
