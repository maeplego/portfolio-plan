# P03 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロジェクト | P03 media-platform |
| 対象スライス | 現行 API + Web。Lambda 本番は未実装 |
| 最終更新 | 2026-08-19 |
| 矛盾時の正 | 自動テストと製品コード、次に `DESIGN.md`。HTTP の細部は [05-api.md](05-api.md) |

単体デモは `?user=` と `X-Dev-User-Sub`。OIDC 時は JWT または opaque + userinfo で `sub`。

アップロード: presign → クライアントが Garage へ PUT → complete。画像なら job `queued`。processor が派生を書き `finish`。非画像はストレージのみ。

共有: 高エントロピートークン。GET `/v1/s/{token}` はメタ、download は署名付き。パスワード任意は計画（未実装なら「無い」）。

purpose: `wiki`, `product`, `blog`, `chat`, `drive`。内部 `service/{service}/` は将来。
