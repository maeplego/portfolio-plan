# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | reliability-platform（GitHub: [pf-reliability](https://github.com/maeplego/pf-reliability)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

## インシデント状態

```mermaid
stateDiagram-v2
  [*] --> triggered
  triggered --> acknowledged: ack
  triggered --> resolved: resolve
  acknowledged --> resolved: resolve
  resolved --> [*]
```

## Webhook の再送と集約

```mermaid
sequenceDiagram
  participant S as Sender
  participant A as pf-reliability API
  participant DB as Postgres
  S->>A: POST /v1/integrations/key/events HMAC
  A->>DB: 未解決を dedup_key で検索
  A-->>S: incident
  S->>A: 同じ event_id
  A-->>S: 同一 incident
```

## 訓練採点（クラスタ操作なし）

```mermaid
flowchart LR
  UI[Web] --> Score[POST /v1/training/score]
  Score --> Eng[packages/scenario]
  Eng -->|rollback| Pass[合格]
  Eng -->|scale| Fail[減点]
```

訓練 UI の本編と履歴は計画。状態機械と採点 HTTP は実装済み。
