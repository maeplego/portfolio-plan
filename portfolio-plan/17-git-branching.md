# Git ブランチ戦略

メタ（`portfolio-plan`）と兄弟 `pf-*`（27 リポジトリ）向け。一人開発〜少数を前提に、**シンプルな trunk-based** を正とする。フル GitFlow（常設 `develop` / `release/*`）は当面採用しない。

## 原則

1. **既定ブランチは `master`**（各 remote `github/master`）。新規リポも合わせる。将来 `main` へ揃える場合は一括リネームし、本ファイルを更新する
2. **`master` は常にデモ可能な状態**を保つ（壊したまま放置しない）
3. **長い寿命のブランチを増やさない**。作業は短命ブランチ → merge → 削除
4. **force push は `master` に対して行わない**（個人の短命ブランチのみ、必要なとき）
5. **横断変更はリポを跨ぐ。** 依存順を守り、同じ意図のコミットメッセージで揃える

## ブランチ命名

| 種類 | パターン | 例 |
| --- | --- | --- |
| 機能 | `feature/Pxx-short-kebab` | `feature/P03-org-tenant` |
| 修正 | `fix/Pxx-short-kebab` | `fix/P10-cookieKey-import` |
| 書類 | `docs/short-kebab` | `docs/licensing` |
| 雑務 | `chore/short-kebab` | `chore/ci-timeout` |
| 横断 | `feature/cross-short-kebab` | `feature/cross-eval-license` |

`Pxx` は主対象。メタのみなら `docs/` または `chore/` でよい。

## 日常の流れ（一人〜少数）

```text
master
  └─ feature/P04-...  （作業）
       ├─ テスト緑
       ├─ master を rebase または merge で追従（好みで可。履歴を単純に保つ）
       └─ master へ merge（GitHub PR 推奨。直接 push も当面可）
  → tag（任意）
```

1. `git switch -c feature/Pxx-...`（`master` 最新から）
2. 小さくコミット（なぜを書く。`--no-verify` 禁止）
3. 製品の所定テストを通す
4. PR を作成して自分でレビューマージ、または `master` へ merge
5. リモートの作業ブランチを削除

**PR を推奨する理由:** 公開リポで差分が残る、CI をかけやすい、誤 push を減らせる。必須にはしない（一人で摩擦が大きいため）。

## `master` の保護（GitHub で推奨）

公開 remote では次を有効化するとよい（設定は人手）。

- `master` への直接 force push 禁止
-（任意）PR 必須 + 自分 approve 可
-（任意）status check（`go test` / `npm test` など製品ごと）

## タグとリリース

デモ段階では必須ではない。パッケージ販売を意識し始めたら製品ごとに:

| タグ | 意味 |
| --- | --- |
| `v0.x.y` | 評価／デモ互換（破壊的変更あり得る） |
| `v1.0.0` | 商用契約のベースライン候補（本番ゲート通過後） |
| `portfolio-snapshot-YYYY-MM-DD` | 全リポ共通の作業スナップショット（横断復元用） |

注釈タグ推奨: `git tag -a v0.3.0 -m "reason"`。  
メタリポは製品バージョンを持たず、必要なら `portfolio-plan` 側に「対応タグ表」を足す。

### 全リポを同じ ref に揃える

`product-repos.json` 掲載のリポを一括 checkout する:

```powershell
cd project
.\scripts\checkout-workspace-ref.ps1 -Status
.\scripts\checkout-workspace-ref.ps1 -Ref portfolio-snapshot-2026-08-21-gaps -Fetch
.\scripts\checkout-workspace-ref.ps1 -Ref portfolio-snapshot-2026-08-21-gaps -WorkBranch
.\scripts\checkout-workspace-ref.ps1 -Ref master
```

最新の横断スナップショットは **`portfolio-snapshot-2026-08-21-gaps`**（P01–P16 A/B ギャップ実装 W0–W6 後）。同日の `portfolio-snapshot-2026-08-21` はその直前の状態。

- 既定のタグ checkout は **detached HEAD**（見るだけ向け）
- その上で触るなら **`-WorkBranch`**（`at/<Ref>` を作って乗る）
- dirty なリポはスキップ（壊さない）

## 複数リポジトリをまたぐ変更

依存の上流から入れる。

1. **P01（IdP）** の契約・シード変更
2. 利用側 `pf-*`（Media / Workspace / Commerce 等）
3. **pf-cloud-k8s**（review pack / overlay / demo 脚本）
4. **portfolio-plan**（DESIGN / docs / REVIEW）

各リポで別 commit／別 PR。メッセージに同じチケットまたは短い共通フレーズを入れる（例: `org tenant:` 接頭）。

片方だけ merge して長時間放置しない。壊れる組み合わせは `master` に残さない。

## 顧客・商用が出てきたら（将来）

現行戦略を捨てず、次を足す。

| 追加 | 用途 |
| --- | --- |
| 顧客用 private fork または private リポ | カスタムは本番顧客ごとに隔離 |
| `release/vX.Y` 短命ブランチ | 複数ホットフィックスをまとめるときだけ |
| `hotfix/*` | `master`（または release タグ）からの緊急修正 |

常設の `develop` は、リリース列車と複数人並行が常態になってから検討する。

## やらないこと

- 全 `pf-*` で別々の GitFlow 方言を育てる
- `master` と意味の違う長期 `main` を混在させたまま放置
- 巨大ブランチを週単位で放置
- ライセンス／秘密を含むコミットを history から消す前提の運用（最初から入れない）

## 関連

- ライセンス: `15-licensing.md`
- CI 方針: `18-ci.md`
- 工程: `01-instructions.md`

最終更新: 2026-08-21
