# 予約カレンダーの書類

> **採用スキム**: 製品 README と DESIGN の「非目標」まで。詳細仕様・ゲート（07+）は深掘り用。

実装は [pf-calendar](https://github.com/maeplego/pf-calendar) です。空き枠の計算、公開予約、キャンセル、リマインドの説明です。文書と実装が違うときは、コードとテストを優先してください。

勤怠（[pf-attendance](https://github.com/maeplego/pf-attendance)）とはつなぎません。求人側からの利用は [pf-talent-api](https://github.com/maeplego/pf-talent-api) です。`calendar.booking.confirmed` の outbox → webhook 受信は実装済みです。

**レビュー到達**: `review-up.ps1` に p05 パックは無い（不要）。単体は Compose（`pf-cloud-k8s` の `demo.ps1 -Key p05`、または `pf-calendar/deploy`）、P10 結合は同カタログの with-p10 か K8s overlay C（`portfolio-integration-c-scheduling-talent`）。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | ホストとゲストから見た時刻の契約 |
| [03-design.md](03-design.md) | 競合、タイムゾーン、永続化 |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | 図表 |
