# P11 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P11 developer-platform |
| 対象スライス | CLI と scanner。portal HTTP は未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md` |

scanner 終了コード: 0 は指定重大度以上なし、1 は finding あり、2 は使い方ミスまたは OSV 不足でグリーン偽装不可。`-offline` は OSV を飛ばす。

`pf-dev new [-t go-api|go-next]` は非空ディレクトリに `-force` が要る。`--yes` は非対話。`pf-dev scan` は scanner を subprocess。テンプレ根は `PF_DEV_TEMPLATES`、既定は兄弟 `pf-developer-templates`。
