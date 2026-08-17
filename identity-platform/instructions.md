# P01 identity-platform — 実装時に読むもの

ユーザーが「P01 を実装して」と言ったら、回答や実装の **前に** 次をこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/identity-platform/DESIGN.md`
5. `portfolio-idea/14-oauth-oidc-identity-provider.md`
6. `identity-platform/chat-context/` 配下の `P01_*.md` をファイル名昇順で全て

他製品を IdP に接続する作業では、利用側プロジェクトの `DESIGN.md` と `instructions.md` も読む。

## このフォルダ

| パス | git |
| --- | --- |
| `identity-platform/instructions.md` | 親リポジトリで管理してよい |
| `identity-platform/chat-context/` | 管理しない |
| `identity-platform/pf-identity-server/` | 独立リポジトリ |
| `identity-platform/pf-identity-admin/` | 独立リポジトリ（未作成なら DESIGN の順で後） |
| `identity-platform/pf-identity-sample-rp/` | 独立リポジトリ（後） |
| `identity-platform/pf-identity-infra/` | 独立リポジトリ |

チャット記録の次ファイル名は `chat-context/P01_XXXXX_要約.md`。XXXXX は既存最大連番 + 1（5桁）。

## 実装の本線

DESIGN の順: 登録とセッション → `/authorize` + Consent → `/token` + PKCE → ID Token / JWKS / Discovery → refresh ローテーション → admin → sample-rp。
