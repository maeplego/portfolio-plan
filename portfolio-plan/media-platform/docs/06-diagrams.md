# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | メディア基盤 [pf-media](https://github.com/maeplego/pf-media) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

マイドライブ UI は実装済み。AWS Lambda 本番経路は未実装のため図に含めない。

```mermaid
flowchart LR
  U[所有者] --> UC1[presign して置く]
  U --> UC2[共有リンクを切る]
  U --> UC3[ドライブ UI]
  G[ゲスト] --> UC4[トークンで取る]
  P[processor] --> UC5[派生を書く]
```

```mermaid
sequenceDiagram
  participant W as Web
  participant A as API
  participant G as Garage
  participant R as Redis
  participant Pr as processor
  W->>A: presign
  W->>G: PUT
  W->>A: complete
  A->>R: job
  Pr->>G: 読み書き
  Pr->>A: finish
```
