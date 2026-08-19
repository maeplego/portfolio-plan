# P01 identity-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P01 identity-platform |
| 対象スライス | 認可コード + PKCE、refresh 回転、管理 UI、sample-rp、logout。メール検証は未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-identity` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書 |
| [02-specification.md](02-specification.md) | 外部仕様書 |
| [03-design.md](03-design.md) | 内部設計書 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | API 仕様書（OIDC エンドポイント） |
| [06-diagrams.md](06-diagrams.md) | 図表 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 登録・ログイン Cookie | 実装済み | 要件、仕様のセッション |
| authorize / consent / token / PKCE | 実装済み | 仕様、シーケンス、TS |
| ID Token / JWKS / Discovery | 実装済み | 05-api |
| refresh 回転 | 実装済み | 設計、テスト |
| 管理 UI・クライアント CRUD | 実装済み | 05-api `/admin/api` |
| sample-rp + logout | 実装済み | デモ、Front/Back-channel |
| メール検証・パスキー・PAR/CIBA | 計画 / 非目標 | 要件の含まない |
