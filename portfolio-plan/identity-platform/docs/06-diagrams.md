# P01 図表

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | 認可コード。画面は実装済みログイン / Consent |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |
| 記法 | Mermaid |

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

未実装: メール検証フロー、パスキー。計画として図に足さない（非目標に近いものは書かない）。
