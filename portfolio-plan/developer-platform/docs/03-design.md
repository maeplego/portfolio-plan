# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | 開発者基盤（GitHub: `pf-developer-cli`、`pf-developer-templates`、`pf-developer-scanner`、`pf-developer-portal`、`pf-developer-ci-dash`、`pf-developer-review`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

ポリレポ。scanner は独立。portal / dash / review は各単一 Go プロセス。

## 1. CLI と scanner

CLI が scanner を import して循環しない。OSV 結果は `.scanner-cache`。Dockerfile は最終ステージの `:latest` / USER root。シークレットは正規表現、レポートはマスク。

## 2. ポータル

portal は Next.js ではなく **Go + 埋め込み HTML**。カタログは起動時に `specs/*.yaml` を yaml.v3 で読む。`$ref` は `#/components/...` のみ。モックは example 優先。JSON Schema は type / required / 基本型だけ。アンカー爆弾対策はサイズ上限。example に AWS キー形・`ghp_`・PEM ヘッダが無いことを `speclint` テストで止める。

## 3. 仕様差分

CI は `oasdiff/oasdiff-action`（ERR で fail）。同じフィクスチャを `internal/specbreak`（path 削除、required 追加、応答プロパティ削除、型変更）で `go test` する。oasdiff 本体を portal の go.mod に入れず、Action と薄いゲートを分けた。

## 4. CI dash / review

GitHub ホストは `GITHUB_API_BASE`（既定 `https://api.github.com`）のみ。owner/name は正規表現と allowlist。クエリの `path=` を拒否してローカル git を開かない。トークンは `Authorization` にだけ載せ、ログに出さない。

## 5. 未実装

管理アップロード、PostgreSQL 版管理、横断 web シェル、フレーク検出、自前ランナー、scanner の Kubernetes。
