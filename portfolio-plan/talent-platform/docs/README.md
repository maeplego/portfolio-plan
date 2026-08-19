# 求人マッチングの書類

実装は [pf-talent-api](https://github.com/maeplego/pf-talent-api) と [pf-talent-web](https://github.com/maeplego/pf-talent-web) です。求人、応募、予約確定後のステータス更新の説明です。OpenSearch は使いません。文書と実装が違うときは、コードとテストを優先してください。

カレンダーは [pf-calendar](https://github.com/maeplego/pf-calendar)、類似求人は [pf-recommend](https://github.com/maeplego/pf-recommend)（失敗時はスキルの重なり）です。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | 候補者と企業から見た振る舞い |
| [03-design.md](03-design.md) | データと認可 |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | 図表 |
