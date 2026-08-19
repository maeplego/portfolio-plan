# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | 推薦エンジン（GitHub: `pf-recommend`） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

記法は Mermaid。

## 1. 目的

バッチ学習 → ファイル成果物 → 推論、および EC BFF の fail-closed を図示する。

## 2. 含む / 含まない

含む: 現行の CLI・API・demo-web・EC 結合。含まない: 未実装の求人 Web シェルやオンライン学習。

## 3. ユースケース

```mermaid
flowchart LR
  Rev[レビュア] --> UC1[demo-web でユーザー切替]
  Talent[求人 API] --> UC2[similar-items jobs]
  Shop[EC BFF] --> UC3[recommend / similar commerce]
  Train[学習 CLI] --> UC4[時間 split で成果物]
```

## 4. 推論（コールドスタート）

```mermaid
sequenceDiagram
  participant W as demo-web
  participant A as API
  W->>A: GET /v1/recommend
  alt 既知ユーザー
    A-->>W: item_item fallback false
  else 未知
    A-->>W: popularity fallback true
  end
```

## 5. EC BFF との関係

```mermaid
sequenceDiagram
  participant BFF as pf-commerce BFF
  participant Rec as pf-recommend
  BFF->>Rec: GET /v1/similar-items namespace=commerce item_id=MUG-1
  alt 200 かつ SKU がカタログにある
    Rec-->>BFF: items TEE-1 ...
    BFF-->>BFF: source recommend
  else 失敗または未マップ
    Rec-->>BFF: 5xx / 404 / 未知 SKU
    BFF-->>BFF: カタログ順 popularity
  end
```

## 6. 受け入れ

図のパス名と namespace が API 仕様・テストと一致していること。
