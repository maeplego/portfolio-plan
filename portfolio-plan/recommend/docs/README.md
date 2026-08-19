# 推薦の書類

実装は [pf-recommend](https://github.com/maeplego/pf-recommend) です。オフライン学習と HTTP 推論の説明です。実顧客ログは使いません。文書と実装が違うときは、コードとテストを優先してください。

呼び出し側の例は求人 [pf-talent-api](https://github.com/maeplego/pf-talent-api) と EC の BFF [pf-commerce](https://github.com/maeplego/pf-commerce) です。失敗時は呼び出し側が自前の一覧へ戻します。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | 推論 API の振る舞い |
| [03-design.md](03-design.md) | 学習と成果物 |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | 図表 |
