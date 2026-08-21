# 招待・公開範囲（顧客向け一枚絵）

| 項目 | 値 |
| --- | --- |
| 対象 | Collab（P04） |
| 最終更新 | 2026-08-21 |

## 誰が何を見られるか

| 相手 | 見えるもの | 見えない／できないこと |
| --- | --- | --- |
| workspace **owner** / **member** | ボード・Wiki（下書き含む）・チャット投稿・招待の管理 | — |
| workspace **guest** | 公開 Wiki・ボード閲覧・チャット閲覧 | 下書き Wiki、投稿、招待作成 |
| **招待リンク**保持者 | accept 画面のみ（期限・失効あり） | 事前に workspace 中身は見えない。メール照合あり |
| **共有メディアリンク** | 対象ファイルのみ（トークン付き） | バケット一覧・他ファイル |
| 未所属・リンクなし | なし | 一覧にも出ない |

## 運用上の約束

- 招待は revoke / resend できる。放置リンクを想定しない
- オブジェクト格納バケットは非公開（presign のみ）
- 詳細の正は [02-specification.md](02-specification.md)。障害時は [07-operations-runbook.md](07-operations-runbook.md)

この一枚絵で [production-definition.md](../../production-definition.md) の「招待・共有リンク公開範囲」Risk Accept を閉じる。
