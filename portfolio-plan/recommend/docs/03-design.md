# P07 内部設計書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P07 recommend |
| 対象スライス | モノレポ。成果物は JSON neighbor リスト |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

`apps/api` FastAPI、`apps/train` CLI、`packages/metrics` 時間 split、`packages/runtime` リクエスト経路でフル行列を読まない。registry は `manifest.json` を最後に書く。MovieLens 本体は git に置かず train 時ダウンロード可。CI は `testdata/ml-tiny`（架空タイトル）。

未実装: implicit/LightFM、Redis キャッシュ、Postgres registry、P06 アダプタ。
