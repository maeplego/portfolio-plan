# 本番・staging プロファイル

| 項目 | 値 |
| --- | --- |
| 対象 | pf-identity `IDENTITY_ENV` |
| 最終更新 | 2026-08-21 |

## `IDENTITY_ENV`

| 値 | 許可 | 拒否 |
| --- | --- | --- |
| `development`（既定） | `IDENTITY_DEV_GENERATE_KEYS`、memory store | — |
| `staging` | postgres + ファイル PEM | 一時鍵生成、memory |
| `production` | 上記 + `IDENTITY_COOKIE_SECURE=true` | staging と同じ禁止に加え insecure cookie |

起動時に違反するとプロセスは fail-fast する（設定エラー）。デモ Compose は `development` のまま。

## 鍵

- 開発: `IDENTITY_DEV_GENERATE_KEYS=true`（再起動でトークン無効化）
- staging/production: `IDENTITY_RSA_PRIVATE_KEY_PATH` のみ。秘密は Git 禁止・秘密管理経由
- ローテ: 新鍵で再デプロイ → JWKS 更新 → 短命 access が自然失効。詳細手順は運用 runbook（Collab 商用化時に拡充）

## 関連

- 監査必須イベント: [08-audit-events.md](08-audit-events.md)
- 脅威モデル: [09-threat-model.md](09-threat-model.md)
- ポートフォリオ本番定義: [../../09-production-definition.md](../../09-production-definition.md)
- BYO IdP: [../../12-portability.md](../../12-portability.md)
