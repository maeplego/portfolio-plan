# P11 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | ポリレポ。scanner は独立モジュール。portal は単一 Go プロセス |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

CLI が scanner を import して循環しない。OSV 結果は `.scanner-cache`。Dockerfile は最終ステージの `:latest` / USER root。シークレットは正規表現、レポートはマスク。

portal は Next.js ではなく **Go + 埋め込み HTML**（このスライス）。カタログは起動時に `specs/*.yaml` を yaml.v3 で読む。`$ref` は `#/components/...` のみ。モックは example 優先。JSON Schema は type / required / 基本型だけ。アンカー爆弾対策はサイズ上限。example に AWS キー形・`ghp_`・PEM ヘッダが無いことを `speclint` テストで止める。

未実装: oasdiff Action、CI webhook、review BFF、管理アップロード、PostgreSQL 版管理。
