# P08 テスト仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P08 content-platform |
| 対象スライス | 1。自動化は shortener `go test ./...` と blog `npm test` |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 製品リポジトリのテスト。本表と食い違ったらテストを直すか本表を追随 |

## 1. 方針

| 層 | やり方 | 目的 |
| --- | --- | --- |
| target / code | DB なし | scheme、allowlist、連番に見えないこと |
| link service | メモリ Store | 作成、期限、他人 403、非同期クリック |
| HTTP | httptest | 401、302、400 |
| visibility / slug | node:test | 下書き非公開、予約 slug |

exploit / PoC は書かない。実在 PII を fixture に置かない。

## 2. 短縮

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-S01 | `javascript:` | 作成エラー | FR-06 |
| TS-S02 | 許可外ホスト | `host_not_allowed` | FR-06 |
| TS-S03 | localhost 記事 URL | 作成成功。code 長 7 | FR-05 |
| TS-S04 | 連続 2 件 | code が一致しない | FR-05 |
| TS-S05 | 数字のみ slug | 拒否 | FR-05 |
| TS-S06 | 期限切れ Resolve | inactive | |
| TS-S07 | 他人の stats | forbidden | |
| TS-S08 | httptest 302 | Location が元 URL。401 はヘッダなし作成 | FR-07 |
| TS-S09 | 非同期クリック | 2s 以内に count>=1 | FR-07 |

## 3. ブログ

| ID | 観点 | 期待 | 要件 |
| --- | --- | --- | --- |
| TS-B01 | draft は isPublic false | 公開に出ない | FR-01 |
| TS-B02 | published + publishedAt<=now | true | FR-01 |
| TS-B03 | 未来の publishedAt | まだ false | FR-01 |
| TS-B04 | slug `admin` | 拒否 | |
| TS-B05 | 下書き公開 URL | 画面 404（Compose で確認） | FR-02 |

## 4. 未自動化

- Compose 実機の管理 Publish と短縮ボタン（契約は TS-S08 + 手動 `/demo`）
- Redis 障害時の DB フォールバック
- Postgres unique 衝突の integration タグ
- Lighthouse（数値を盛らない。未計測）
