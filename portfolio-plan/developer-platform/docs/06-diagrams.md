# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | 開発者基盤（GitHub: `pf-developer-cli`、`pf-developer-scanner`、`pf-developer-portal`、`pf-developer-ci-dash`、`pf-developer-review`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

記法は Mermaid。横断 web シェルは点線（未実装）。

```mermaid
flowchart LR
  Dev[開発者] --> UC1[pf-dev new]
  Dev --> UC2[scanner でゲート]
  Dev --> UC3[portal で spec を見る]
  Dev --> UC4[mock を叩く]
  Dev --> UC5[oasdiff で breaking を止める]
  Dev --> UC6[CI dash で Actions を見る]
  Dev --> UC7[review BFF で PR を見る]
  Dev -.-> UC8[web シェル 未実装]
```

## ポータル画面遷移（実装済み）

```mermaid
flowchart TD
  Cat[GET / カタログ] --> Docs[GET /docs/slug リファレンス]
  Docs --> Try[Try it out]
  Try --> Mock["/mock/slug へ fetch"]
  Mock -->|example| OK[2xx JSON]
  Mock -->|必須欠落| Bad[400 invalid_request]
```

## oasdiff / GitHub BFF

```mermaid
sequenceDiagram
  participant PR as Pull request
  participant GA as GitHub Actions
  participant OA as oasdiff-action
  participant Dash as ci-dash
  participant GH as api.github.com
  PR->>GA: specs changed
  GA->>OA: base SHA vs head YAML
  OA-->>GA: fail on ERR
  Dash->>GH: GET /repos/o/n/actions/runs
  GH-->>Dash: public runs JSON
```
