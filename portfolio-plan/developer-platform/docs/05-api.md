# P11 API 仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | CLI。HTTP ポータルは計画（未実装と書く） |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

HTTP API はまだ無い。契約はコマンド。

```
scanner scan [-offline] [-min-severity] [-o report.md] <root>
pf-dev new [-t go-api|go-next] [--module] [--yes] [-force] [-o] <name>
pf-dev create [-o] api|next <name>
pf-dev scan [-offline] <root>
```

計画: OpenAPI カタログ、モック、oasdiff ゲート。受け入れに入れない。
