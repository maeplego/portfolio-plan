# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | data-platform（GitHub: [pf-data](https://github.com/maeplego/pf-data)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## DAG

```mermaid
flowchart LR
  CSV[架空 CSV] --> MinIO
  MinIO --> Gate[品質ゲート]
  Gate -->|ok| Raw[raw]
  Gate -->|ng| Fail[job_runs failed]
  Raw --> Stg[staging]
  Stg --> Mart[marts]
  Mart --> SQL[marts_kpis.sql]
  Mart --> MB[Metabase profile bi]
```

Metabase は任意プロファイル。パイプライン本体とは独立に起動する。

## 失敗時

```mermaid
sequenceDiagram
  participant P as pipeline
  participant G as validate
  participant M as marts
  P->>G: PIPELINE_SOURCE=broken
  G-->>P: fail
  Note over M: 昨日の行のまま
  P->>P: ops.job_runs failed
```
