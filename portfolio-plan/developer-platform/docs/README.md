# P11 developer-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | scanner MVP + CLI/templates + portal MVP。CI dashboard / review / oasdiff Action は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-developer-scanner` / `../pf-developer-cli` / `../pf-developer-templates` / `../pf-developer-portal` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書 |
| [02-specification.md](02-specification.md) | 外部仕様書 |
| [03-design.md](03-design.md) | 内部設計書 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書 |
| [05-api.md](05-api.md) | CLI / scanner / portal HTTP |
| [06-diagrams.md](06-diagrams.md) | 図表 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| scanner MVP | 実装済み | 要件、05-api、TS |
| CLI + templates（P04/P06 実ファイル） | 実装済み | 仕様、設計 |
| portal MVP（手置き OpenAPI + モック） | 実装済み | 仕様、05-api、図表 |
| oasdiff Action / CI dash / review | 計画 | 受け入れに含めない |
