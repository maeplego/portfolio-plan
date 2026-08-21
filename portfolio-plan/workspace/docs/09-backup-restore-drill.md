# バックアップ／リストア実演記録（テンプレ）

| 項目 | 値 |
| --- | --- |
| 対象 | Collab（P01 IdP DB + P04 Workspace DB。± P03 media DB） |
| 用途 | [production-definition.md](../../production-definition.md) の「staging で一度実演」ゲート |

未記入のまま Go 判定しない。架空／同意済みデータのみ。

## 記録欄

| 項目 | 記入 |
| --- | --- |
| 日付（UTC） | 2026-08-21 |
| 環境 | overlay B staging（`docker-desktop-b-collab-staging`） |
| 担当 | portfolio agent（ローカル Docker Desktop Kubernetes） |
| 対象 DB | idp / workspace（media は今回対象外） |
| バックアップ手段 | `pg_dump -Fc`（platform Postgres Pod 内） |
| バックアップ成果物の保管場所 | ホスト TEMP `pf-collab-backup-drill-20260821/`（`idp.dump` / `workspace.dump`。Git に置かない） |
| リストア先 | 同一クラスタ内 `idp_drill` / `workspace_drill` |
| 所要時間 | 約 5–10 分（dump・restore・短時間 cutover 含む） |
| 結果 | **Pass** |
| 残課題 | media DB の同様実演は任意。顧客環境ではマネージドスナップショット手順を契約に合わせる |

## 実演で確認したこと

1. `idp` / `workspace` を custom format で dump
2. `idp_drill` / `workspace_drill` へ `pg_restore`（public テーブル数一致: idp 12 / workspace 18）
3. IdP を一時的に `idp_drill` へ向け `/health` と `/jwks.json` 応答を確認後、primary に戻す
4. Workspace API を一時的に `workspace_drill` へ向け postgres 起動・`/health` `/ready` を確認後、primary に戻す
5. cutback 後 `workspace.localhost` → IdP authorize リダイレクトを再確認

## 推奨手順（Postgres 論理バックアップ）

1. バックアップ前にアプリを read-only にするか、短いメンテ窓を取る（デモは停止でも可）。
2. `pg_dump -Fc`（または同等）で idp / workspace を取得。ファイル名に日時を入れる。
3. 別 DB または空クラスタへ `pg_restore`。
4. アプリの `DATABASE_URL` をリストア先に向け再起動。
5. 確認: IdP ログイン 1 回、workspace ホーム表示、既知 workspace が 1 件以上見える。org 切替ができること。
6. 失敗時は旧 URL に戻し、記録欄に原因を書く。

## 関連

- [07-operations-runbook.md](07-operations-runbook.md)
- [collab-staging.md](../../collab-staging.md)
