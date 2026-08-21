# バックアップ／リストア実演記録（テンプレ）

| 項目 | 値 |
| --- | --- |
| 対象 | Collab（P01 IdP DB + P04 Workspace DB。± P03 media DB） |
| 用途 | [production-definition.md](../../production-definition.md) の「staging で一度実演」ゲート |

未記入のまま Go 判定しない。架空／同意済みデータのみ。

## 記録欄

| 項目 | 記入 |
| --- | --- |
| 日付（UTC） | |
| 環境 | staging / Compose staging / overlay B staging |
| 担当 | |
| 対象 DB | idp / workspace / media |
| バックアップ手段 | `pg_dump` / マネージドスナップショット / その他 |
| バックアップ成果物の保管場所 | （パスまたはオブジェクトキー。秘密は書かない） |
| リストア先 | 別 DB 名 or 一時 namespace |
| 所要時間 | |
| 結果 | Pass / Fail |
| 残課題 | |

## 推奨手順（Postgres 論理バックアップ）

1. バックアップ前にアプリを read-only にするか、短いメンテ窓を取る（デモは停止でも可）。
2. `pg_dump -Fc`（または同等）で idp / workspace を取得。ファイル名に日時を入れる。
3. 別 DB または空クラスタへ `pg_restore`。
4. アプリの `DATABASE_URL` をリストア先に向け再起動。
5. 確認: IdP ログイン 1 回、workspace ホーム表示、既知 workspace が 1 件以上見える。org 切替ができること。
6. 失敗時は旧 URL に戻し、記録欄に原因を書く。

## 関連

- [07-operations-runbook.md](../workspace/docs/07-operations-runbook.md)
- [collab-staging.md](../../collab-staging.md)
