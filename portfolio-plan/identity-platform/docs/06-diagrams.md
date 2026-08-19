# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | 認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid |

ログイン画面と Consent は実装済み。メール検証やパスキーは図に含めない（未実装または非目標）。

```mermaid
flowchart LR
  U[ユーザー] --> UC1[登録・ログイン]
  U --> UC2[Consent]
  RP[RP] --> UC3[認可コード交換]
  RP --> UC4[UserInfo]
  RP --> UC5[Logout]
  Adm[管理者] --> UC6[クライアント登録]
```

```mermaid
sequenceDiagram
  participant B as Browser
  participant RP
  participant IdP
  B->>RP: ログイン
  RP->>IdP: /authorize + PKCE
  IdP->>B: ログイン / Consent
  IdP->>RP: code
  RP->>IdP: /token
  IdP->>RP: tokens
```
