# EC の書類

> **採用スキム**: 製品 README と DESIGN の「非目標」まで。詳細仕様・ゲート（07+）は深掘り用。

実装は [pf-commerce](https://github.com/maeplego/pf-commerce) です。在庫引当、注文、決済モック、購入者画面の説明です。本物のカード番号は扱いません。文書と実装が違うときは、コードとテストを優先してください。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | 購入者と運用画面から見た振る舞い |
| [03-design.md](03-design.md) | プロセス分割、補償、outbox |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | 公開 REST と GraphQL |
| [06-diagrams.md](06-diagrams.md) | 図表 |
| [07-commerce-gate.md](07-commerce-gate.md) | 商用ゲート自己監査 |
| [08-backup-restore-drill.md](08-backup-restore-drill.md) | staging バックアップ実演記録 |
