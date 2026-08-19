# 要件定義書

| 項目 | 値 |
| --- | --- |
| プロダクト | 求人マッチング（API [pf-talent-api](https://github.com/maeplego/pf-talent-api)、Web [pf-talent-web](https://github.com/maeplego/pf-talent-web)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 1. 背景と目的

架空の IT 求人と候補者の検索・応募・ステータス管理。検索品質（フィルタ、ファセット、日本語）が本領である。予約は予約カレンダー [pf-calendar](https://github.com/maeplego/pf-calendar) を呼び、類似求人は推薦エンジン [pf-recommend](https://github.com/maeplego/pf-recommend) を呼ぶ。どちらもこのリポジトリに再実装しない。

学習用であり、実在求人のクローリングや ATS 全機能の置き換えではない。シードに実在企業名・実在人物を使わない。

## 2. 含む

- 求人 CRUD（draft / published）、応募、プロフィール、通報
- 検索フィルタ（q, employmentType, remote, skills, salary）とファセット件数
- Postgres `tsvector` + `pg_trgm`（Compose の正は Postgres。メモリ店舗だけの常時運用は想定しない）
- 保存検索と手動 run（新着マッチ）
- 応募ステータス。書類通過後に面接候補スロットを提示する。予約確定 webhook で `interview` に更新する（ここでの interview は **選考の面接**）
- 類似求人。推薦 API があれば優先し、失敗または品質不足ならスキル重なりへ閉じる（fail-closed）
- 候補者検索 UI と企業画面。応募一覧は当事者以外 403
- overlay C（`talent.localhost` / `talent-api.localhost`）

## 3. 含まない

| 項目 | 理由 |
| --- | --- |
| OpenSearch / 独立 indexer | 件数が増えたら足す。いまは Postgres FTS |
| 候補者・企業の本番 OIDC | 開発ヘッダ `X-Dev-User-Sub`。認証基盤 [pf-identity](https://github.com/maeplego/pf-identity) は後続 |
| 実在求人のクローリング、課金・掲載プラン | 範囲外 |
| ATS 全機能（課題管理） | ワークスペース [pf-workspace](https://github.com/maeplego/pf-workspace) に任せ、埋め込まない |
| カレンダー UI のコピー | 予約は `http://localhost:3005/book/<slug>` へのリンク |

## 4. アクター

| アクター | 定義 | 認証 |
| --- | --- | --- |
| employer | 求人を作成し応募者を見る | `X-Dev-User-Sub` |
| candidate | 検索し応募する | 同上。Web は `?user=` 必須、ゲストなし |
| admin | 通報の閲覧 | 開発ヘッダ |
| 予約カレンダー | `calendar.booking.confirmed` を webhook で通知 | `X-Calendar-Event-Type` とヘッダ整合 |
| 推薦エンジン | `similar-items?namespace=jobs` | 任意。未接続時はスキル重なり |

## 5. 前提

- ID は ULID。年収は数値範囲。「応相談」は null 範囲 + フラグ
- Compose は専用 Postgres。overlay は platform Postgres の DB 名 `talent`
- 応募時に求人をスナップショットする
- 公開デモは応募メールを実送しない

## 6. 機能要件

| ID | 要件 | なぜ |
| --- | --- | --- |
| FR-01 | 求人を作成・取得できる（`POST /v1/jobs`、`GET /v1/jobs/:id`） | 掲載の正 |
| FR-02 | 公開検索は published のみ。`q` は全文検索と trigram 部分一致を OR する | 日本語の途中一致 |
| FR-03 | 候補者は応募を作成し、自分の応募だけ一覧できる | 認可 |
| FR-04 | 企業は自分の求人の応募だけ一覧できる。当事者以外は 403 | 他社漏洩 |
| FR-05 | 応募ステータス更新は不正遷移を 409 にする | 状態機械 |
| FR-06 | `externalRef`（求人 id）でカレンダーと連携し、webhook で一致する応募を `interview` にする。該当なしは `200 { ok: true, matched: false }` | リトライ可能性。選考の面接 |
| FR-07 | 書類通過後（`document_passed` または `interview`）に面接スロットを提示できる | カレンダー再実装をしない |
| FR-08 | 保存検索の登録・一覧・run ができる | 新着 |
| FR-09 | `GET /v1/jobs/:id/similar` は推薦を優先し、失敗またはスキル重なりが劣るときは fallback | 検索本体を推薦停止で壊さない |
| FR-10 | ファセット件数と通報の保存・一覧 | 管理の最小形 |
| FR-11 | プロフィール PUT/GET | 応募者情報 |
| FR-12 | Web は API 未起動でも立ち上がり、接続エラーを表示する | 単独起動 |
| FR-13 | 架空求人シード（8〜12 件）。実在企業名禁止 | 公開前提 |

## 7. 非機能

| ID | 要件 | なぜ |
| --- | --- | --- |
| NFR-01 | Compose / overlay の検索は Postgres。OpenSearch を前提にしない | 段階化 |
| NFR-02 | webhook 入力はスキーマ検証。不正は `400 invalid_request` | 契約 |
| NFR-03 | 失敗時に秘密をログに出さない | 共通規約 |
| NFR-04 | 応募一覧の ACL はサーバー側。UI 非表示だけでは足りない | 認可 |

## 8. 受け入れ

1. 公開検索でフィルタ後の一覧件数とファセット `total` が一致する
2. 同じ応募が候補者と企業で見え方が違う。他社は 403
3. 不正なステータス遷移が 409
4. 保存検索の run が `matchedJobs` と `matchedCount` を返す
5. `document_passed` でカレンダー未接続なら「カレンダー未接続」。接続時は予約リンク
6. webhook で `interview` に更新される。該当なしは `matched: false` の 200
7. 類似求人に `source` が付き、推薦停止時はスキル重なりへ閉じる
8. Compose 再起動後も求人が Postgres から戻る
