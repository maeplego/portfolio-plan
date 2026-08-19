# P12 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P12 reliability-platform |
| 対象スライス | メモリストア。Postgres は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

`apps/api` Go、`apps/web` Next.js、`packages/scenario` は破壊的 I/O なし。Compose 再起動で状態消失。P02 アラート送信は未配線。P06 は物語上の依存のみ。
