# P11 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | ポリレポ。scanner は独立モジュール |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

CLI が scanner を import して循環しない。OSV 結果は `.scanner-cache`。Dockerfile は最終ステージの `:latest` / USER root。シークレットは正規表現、レポートはマスク。

未実装: portal、oasdiff Action、CI webhook、review BFF。
