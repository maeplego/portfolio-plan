# P02 cloud-platform

「P02 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/01-instructions.md`
2. 本ファイル（なければ `cloud-platform/instructions.md`）
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/cloud-platform/DESIGN.md`
5. `portfolio-idea/16-terraform-three-tier-infra.md`
6. `portfolio-idea/17-kubernetes-microservices.md`
7. `portfolio-idea/18-observability-stack.md`
8. `cloud-platform/chat-context/` の `P02_*.md` をファイル名昇順で全て
9. 連携デモを触るときは `portfolio-plan/07-integration-demo.md` も読む

製品コードはワークスペースの兄弟リポジトリ:

- `../pf-cloud-o11y` — フェーズ 0 優先（Compose 観測）
- `../pf-cloud-k8s` — 連携デモの kustomize 束ね役。overlay D は P06 フル + P07（P11/P12/P13 は後続）
- `../pf-cloud-aws` — アイデア 16 Terraform 3-tier。最初のスタック配線は P09 attendance。モジュールが成果物。**`apply` は非目標**（fmt + validate）

チャット記録の次ファイルは `chat-context/P02_XXXXX_要約.md`（既存最大連番 + 1）。
