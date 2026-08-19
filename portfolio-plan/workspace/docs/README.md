# P04 workspace — 書類索引

| 項目 | 値 |
| --- | --- |
| プロジェクト | P04 workspace |
| 対象スライス | 1–6 実装済み（workspace + カンバン + Wiki + collab + chat + 横断検索 / メンション / 添付）。7 は計画 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | `../pf-workspace` のテストとコード、次に `../DESIGN.md` |

実装チャット用の短い設計は親の `DESIGN.md`。本ディレクトリは面接・レビュー用。書き方の正本は `portfolio-plan/documentation.md`。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 要件定義書。誰の課題か、含む/含まない、受け入れ |
| [02-specification.md](02-specification.md) | 外部仕様書。メンバーと API / 画面から見た振る舞い |
| [03-design.md](03-design.md) | 内部設計書。権限、楽観ロック、CRDT 境界、メモリ store |
| [04-test-spec.md](04-test-spec.md) | テスト仕様書。自動化済みと未自動化 |
| [05-api.md](05-api.md) | API 仕様書。現状の HTTP 契約 |
| [06-diagrams.md](06-diagrams.md) | ユースケース、画面遷移、シーケンス、ER 相当 |

## スライスと書類の対応

| スライス | 状態 | 主に効く書類 |
| --- | --- | --- |
| 1 workspace + メンバー + 認証 | 実装済み | 要件 FR-01–04、仕様のロール、API `/v1/workspaces` |
| 2 カンバン MVP | 実装済み | 要件 FR-05–08、設計の version、TS-K*、画面 |
| 3 Wiki ツリー + 単一 Markdown | 実装済み | 要件 FR-09–12、仕様のページ、API `/v1/pages`、TS-P* |
| 4 collab（CRDT） | 実装済み | 要件 FR-13–16、仕様の collab / Docs、API チケットと internal |
| 5 チャット | 実装済み | 要件 FR-17–19、仕様のチャンネル、API `/v1/channels`、`/chat/ws` |
| 6 横断検索・メンション・P03 添付 | 実装済み | 要件 FR-20–22、仕様の検索 / メンション / 添付、API `/search` と uploads |
| 7 スプリントバーンダウン・Wiki diff | 計画 | 同上 |
