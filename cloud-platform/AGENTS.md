# P02 cloud-platform

「P02 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/instructions.md`
2. 本ファイル（なければ `cloud-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/cloud-platform/DESIGN.md`
5. `portfolio-idea/16-terraform-three-tier-infra.md`
6. `portfolio-idea/17-kubernetes-microservices.md`
7. `portfolio-idea/18-observability-stack.md`
8. `cloud-platform/chat-context/` の `P02_*.md` をファイル名昇順で全て
9. 連携デモを触るときは `portfolio-plan/integration-demo.md` も読む

製品コードはワークスペースの兄弟リポジトリ:

- `../pf-cloud-o11y` — フェーズ 0 優先（Compose 観測）
- `../pf-cloud-k8s` — 連携デモの kustomize 束ね役（`portfolio-integration` overlay）。P06 overlay は後追い
- `../pf-cloud-aws` — アプリ載せ先が決まってから Terraform

チャット記録の次ファイルは `chat-context/P02_XXXXX_要約.md`（既存最大連番 + 1）。
