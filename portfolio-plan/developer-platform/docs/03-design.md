# P11 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | ポリレポ。scanner は独立。portal / dash / review は各単一 Go プロセス |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

CLI が scanner を import して循環しない。OSV 結果は `.scanner-cache`。Dockerfile は最終ステージの `:latest` / USER root。シークレットは正規表現、レポートはマスク。

portal は Next.js ではなく **Go + 埋め込み HTML**。カタログは起動時に `specs/*.yaml` を yaml.v3 で読む。`$ref` は `#/components/...` のみ。モックは example 優先。JSON Schema は type / required / 基本型だけ。アンカー爆弾対策はサイズ上限。example に AWS キー形・`ghp_`・PEM ヘッダが無いことを `speclint` テストで止める。

仕様差分: CI は `oasdiff/oasdiff-action`（ERR で fail）。同じフィクスチャを `internal/specbreak`（path 削除、required 追加、応答プロパティ削除、型変更）で `go test` する。oasdiff 本体を portal の go.mod に入れず、Action と薄いゲートを分けた。

CI dash / review: GitHub ホストは `GITHUB_API_BASE`（既定 `https://api.github.com`）のみ。owner/name は正規表現と allowlist。クエリの `path=` を拒否してローカル git を開かない。トークンは `Authorization` にだけ載せ、ログに出さない。

未実装: 管理アップロード、PostgreSQL 版管理、横断 web シェル、フレーク検出、自前ランナー。
