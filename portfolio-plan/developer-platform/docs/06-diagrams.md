# P11 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | scanner + CLI + portal MVP。CI dash / review は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 記法 | Mermaid |

```mermaid
flowchart LR
  Dev[開発者] --> UC1[pf-dev new]
  Dev --> UC2[scanner でゲート]
  Dev --> UC3[portal で spec を見る]
  Dev --> UC4[mock を叩く]
  Dev -.-> UC5[CI dash_計画]
  Dev -.-> UC6[PR review_計画]
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
