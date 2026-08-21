# P06 commerce-platform

「P06 を実装して」と言われたら、回答や実装の前にこの順で読む。

1. `portfolio-plan/01-instructions.md`
2. 本ファイル
3. `portfolio-plan/00-overview.md`
4. `portfolio-plan/commerce-platform/DESIGN.md`
5. `portfolio-idea/05-ecommerce-order-microservices.md`
6. `portfolio-idea/06-realtime-inventory-dashboard.md`
7. `portfolio-idea/24-graphql-bff.md`
8. `portfolio-idea/25-event-sourcing-orders.md`
9. `commerce-platform/chat-context/` の `P06_*.md` をファイル名昇順で全て
10. 書類の更新・面接説明では `portfolio-plan/02-documentation.md` と `portfolio-plan/commerce-platform/docs/README.md`

K8s は P02、画像は P03、推薦は P07。overlay D は P01+P02+P03+P06 フル + P07（P11/P12/P13 は後続）。

製品コードはワークスペースの兄弟 `../pf-commerce`（`apps/catalog` / `inventory` / `order` / `payment` / `notify` / `api` gateway / `bff` / `storefront` / `ops-web`、`deploy`）。このフォルダは設計・指示・チャット記録用。

チャット記録の次ファイルは `chat-context/P06_XXXXX_要約.md`（既存最大連番 + 1）。
