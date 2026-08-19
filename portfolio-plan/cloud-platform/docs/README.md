# クラウド基盤の書類

実装は [pf-cloud-o11y](https://github.com/maeplego/pf-cloud-o11y)、[pf-cloud-k8s](https://github.com/maeplego/pf-cloud-k8s)、[pf-cloud-aws](https://github.com/maeplego/pf-cloud-aws) です。このフォルダは観測・ローカル Kubernetes・Terraform モジュールの説明です。AWS へ本番デプロイはしません。文書と実装が違うときは、コードとテストを優先してください。

起動の手順は [REVIEW.md](../../REVIEW.md) です。Kubernetes の URL 一覧は `pf-cloud-k8s/docs/` です。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | Compose と Kubernetes の見え方 |
| [03-design.md](03-design.md) | overlay、3-tier、計装 |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | health / OTLP / サンプル API |
| [06-diagrams.md](06-diagrams.md) | 図表 |
