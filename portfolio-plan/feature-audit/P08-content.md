# P08 content-platform — 機能再確認

| 項目 | 値 |
| --- | --- |
| 監査日 | 2026-08-21 |
| 製品リポ | `../pf-content-blog`、`../pf-content-shortener`、`../pf-content-infra` |
| 設計 | [content-platform/DESIGN.md](../content-platform/DESIGN.md) |
| 優先 | コード・テスト → DESIGN → docs |

---

## 1. 識別

| 項目 | 値 |
| --- | --- |
| ID | **P08** |
| 元アイデア | 07 技術ブログ CMS、09 URL 短縮＋クリック分析 |
| 役割 | 公開コンテンツ基盤（ブログ＋短縮）。ホットパス（302）だけ別プロセス |
| 構成 | blog（Next 公開＋管理）、shortener（Go）、infra（Compose 束ね役） |

シード記事は架空 Harbor Press。本番 CMS／短縮サービスの置き換えではない。

---

## 2. 目的・スコープ

**目的:** 技術発信と記事・デモ URL の短いリンクを一つの公開基盤にする。ブログ単体でも成立。管理から「記事の短縮 URL」を作れる。

**含む:** DB 駆動 CMS、下書き／公開、Draft Mode、RSS／sitemap、OG 画像、短縮作成・302・非同期クリック、許可ホスト、管理グラフ、任意 P03 cover、ブログ側 OIDC コードパス、レート制限・k6 スクリプト。

**技術:** Next.js＋Markdown＋Postgres、Go＋Redis＋Postgres、infra Compose。Tailwind＋MDX は DESIGN 上「未」。

---

## 3. 実装済み機能

### 3.1 ブログ公開（`:3007`）

| 面 | 内容 |
| --- | --- |
| 一覧／記事 | 公開のみ。下書きは匿名 404 |
| Draft Mode | 編集者＋Draft Mode 同時のみ下書きプレビュー |
| RSS／sitemap | `/rss.xml`、`/sitemap.xml` |
| OG | `/posts/{slug}/opengraph-image`（下書き題は出さない） |
| robots | サイト全体 `index: false`。`/admin` も拒否想定 |
| `/demo` | 画面上の確認手順 |

**Markdown:** `javascript:`／`data:` は `<a href>` にしない。

### 3.2 ブログ API（管理・公開）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/api/health`、`/api/ready` | 運用 |
| GET | `/api/posts` | 公開一覧。`?all=1` は編集者 |
| GET/POST/PATCH | `/api/posts`、`/api/posts/{id}` | CRUD・公開 |
| POST | `/api/posts/{id}/shorten` | 公開記事のみ短縮作成 |
| POST/DELETE/GET | `/api/draft` | Draft Mode |
| POST | `/api/dev-login` | `CONTENT_DEV_AUTH` |
| GET | `/api/session` | セッション |
| GET | `/api/short-links` | 短縮一覧／stats（サーバ経由） |
| POST | `/api/media/upload` | `MEDIA_API_URL` 時 cover |

### 3.3 短縮（`:8094`）

| メソッド | パス | 内容 |
| --- | --- | --- |
| GET | `/health`、`/ready` | 運用 |
| POST | `/v1/links` | 作成（slug／expiresAt 任意） |
| GET | `/v1/links`、`/{id}`、`/{id}/stats` | 作成者のみ。日次件数 |
| GET | `/{code}` | **302 先**。クリックは非同期。生 IP 非保存（ハッシュで RL） |

コードは連番禁止。http(s) のみ。`SHORTENER_ALLOW_HOSTS` 外は 400。リダイレクト RPM 制限あり。

### 3.4 infra

Postgres（blog＋shortener DB）＋Redis＋両サービス。`compose.media.yaml` で P03。`scripts/compose-smoke.mjs`。

### 3.5 無いもの

予約投稿、全文検索、コメント、QR、パスワード付きリンク、短縮の P01 OIDC、マルチテナント独自ドメイン、メディア企業級 CMS。

---

## 4. 認証・テナント・環境変数

| 主体 | 方式 |
| --- | --- |
| 公開読者 | 匿名 |
| ブログ編集 | `CONTENT_DEV_AUTH`＋dev-login cookie、**または** blog の `OIDC_*`（コードあり。Compose 既定は未配線） |
| 短縮 API | **`SHORTENER_DEV_AUTH`＋`X-Dev-User-Sub` のみ**（OIDC 未配線。config が明示） |
| cover | Media へ Bearer または `X-Dev-User-Sub` 転送 |

**テナント:** なし（単一編集者デモ）。

**主要 env（infra）:** `CONTENT_*`、`SHORTENER_*`、`SHORTENER_API_URL`、任意 `MEDIA_API_URL`。blog OIDC は `OIDC_ISSUER`／`CLIENT_ID`／`REDIRECT_URI` 等（infra `.env.example` には未掲載）。

---

## 5. デモ起動

```powershell
cd pf-content-infra/deploy
copy .env.example .env
docker compose up -d --build
```

| URL | 用途 |
| --- | --- |
| http://localhost:3007 | 公開ブログ |
| http://localhost:3007/demo | 手順 |
| http://localhost:3007/admin | 開発ログイン → 下書き／公開／短縮グラフ |
| http://localhost:8094/health | 短縮 |

P03 cover: `compose.media.yaml`＋ホストで pf-media。  
K8s: `pf-cloud-k8s` の content overlay（`e-content`）。DESIGN どおり overlay E は Compose 安定後。

---

## 6. 他 Pxx との契約

| 相手 | 契約 |
| --- | --- |
| **P03** | 任意。`MEDIA_API_URL` で cover presign |
| **P01** | blog 管理 OIDC は実装パスあり。shortener／infra Compose 既定は dev-auth。backlog: shortener OIDC 未配線 |
| **P02** | 3-tier／K8s overlay 候補。上流依存なし |
| **P11** | 短縮 API をポータル登録する想定（下流） |

ブログ→短縮はサーバ側 `SHORTENER_API_URL`＋`X-Dev-User-Sub`。Next に 302 を載せない。

---

## 7. 非目標・名乗らないこと

メディア企業級 CMS、ユーザーが独自ドメインを繋ぐマルチテナント短縮、本番 CMS／短縮置き換え、コメント／スパム対策込み SNS。

---

## 8. テスト・ゲート

| 層 | 状態（監査時点） |
| --- | --- |
| blog `npm test` | 可視性・OG・slug 等（CI） |
| blog Playwright | `test:e2e`（workflow 別。メモリ store） |
| shortener `go test ./...` | 作成・許可リスト・RL 等 |
| infra smoke | `compose-smoke.mjs`（手動／レビュー） |
| CI（blog） | unit、npm audit、Trivy、kustomize |
| k6 | `pf-content-shortener/scripts/k6-redirect.js`（任意負荷） |

---

## 9. ギャップ／注意点

| # | 内容 | 備考 |
| --- | --- | --- |
| 1 | shortener に P01 OIDC なし | DESIGN「管理は P01」と backlog が一致。作成 API は dev ヘッダ依存 |
| 2 | infra Compose に blog OIDC env なし | コードはあるがデモ既定は dev-auth |
| 3 | DESIGN「P01・レート制限・k6」は短絡的に「完了」 | レート制限・k6 は shortener。OIDC は blog のみ部分 |
| 4 | Tailwind＋MDX 未 | Markdown＋小さな CSS |
| 5 | 予約投稿・検索・コメントなし | README／DESIGN どおり |
| 6 | docs/05-api 最終更新 2026-08-19 | 大筋は一致。OIDC 詳細は薄い |
| 7 | 公開デモ許可ホストは localhost 系 | 本番ホスト許可の運用は別 |

---

## 10. 根拠パス

- メタ: `portfolio-plan/content-platform/DESIGN.md`、`docs/*`、`content-platform/AGENTS.md`、idea 07／09
- 製品: `pf-content-blog/app/api/**`、`lib/visibility.ts`、`pf-content-shortener/internal/web/server.go`、`internal/auth/auth.go`、`pf-content-infra/deploy/compose.yaml`
- 連携: `pf-cloud-k8s` content overlay、任意 `pf-media`
