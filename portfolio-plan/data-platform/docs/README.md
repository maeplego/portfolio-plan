# データパイプラインの書類

実装は [pf-data](https://github.com/maeplego/pf-data) です。架空 CSV から品質ゲート、dbt の集計表までの説明です。本番 DWH や実在個人のデータは使いません。文書と実装が違うときは、コードとテストを優先してください。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | DAG と KPI |
| [03-design.md](03-design.md) | extract / ゲート / marts |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | 実行契約（製品 HTTP API はない） |
| [06-diagrams.md](06-diagrams.md) | 図表 |
