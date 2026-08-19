# P08 content-platform — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P08 content-platform |
| 対象スライス | 1–2 実装済み（CMS + 短縮 MVP + Draft Mode/OG + 日次グラフ）。Tailwind+MDX / P01 / P03 / k6 は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-content-blog` / `../pf-content-shortener` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。読者と編集者から見た振る舞い |
| [03-design.md](03-design.md) | 内部設計書。プロセス分割、コード生成、クリック非同期 |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面遷移、シーケンス、状態、ER |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 Markdown + CMS 下書き/公開 + 短縮 MVP | 実装済み | 要件 FR、仕様の公開/下書き、設計のホットパス、TS-* |
| 2 OG / Draft Mode | 実装済み（MDX/Tailwind は未） | 仕様の Draft Mode。OG は公開記事のみ |
| 3 記事に紐づく短縮の日次グラフ UI | 実装済み | 管理画面バー。API `/v1/links/{id}/stats` |
| シード「15 にまとめた理由」 | 実装済み | `why-fifteen-products`。やらなかったことを記事に書く |
| 4 P03 / P01 / レート制限 / k6 | 計画 | |
| overlay E | 実装済み（P08。P11 なし） | `pf-cloud-k8s` `e-content` |
