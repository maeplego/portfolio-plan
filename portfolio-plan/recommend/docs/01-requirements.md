# P07 要件定義書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P07 recommend |
| 対象スライス | 受け入れは MovieLens 形フィクスチャ。実顧客ログは含めない |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

学習と推論を切り出し、P06 / P10 が独自 pickle を持たない。学習用。実ユーザー購買を Git に置かない。

含む: 人気ベース、item-item cosine、時間 split、未知ユーザーは popularity + `fallback: true`、`GET /v1/similar-items`、CLI 学習。含まない: リアルタイム学習、公開 HTTP train、ANN クラスタ、ランダム split を完成扱い、P06 イベントアダプタ。

受け入れ: ユーザー切替でリストが変わる、メトリクス表、新規ユーザーが fallback、未知 item は 404（P10 は自前フォールバック）。
