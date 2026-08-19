# 外部仕様書

| 項目 | 値 |
| --- | --- |
| プロダクト | talent-platform（GitHub: [pf-talent-api](https://github.com/maeplego/pf-talent-api)、[pf-talent-web](https://github.com/maeplego/pf-talent-web)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する。HTTP の細部は [05-api.md](05-api.md) |

候補者と企業から見た求人検索・応募・応募ステータス。予約の空き計算は [pf-calendar](https://github.com/maeplego/pf-calendar) に任せる。類似求人の学習モデルは [pf-recommend](https://github.com/maeplego/pf-recommend) があれば使う。

## 時刻

この範囲では応募の業務時刻を保持・表示しない。カレンダー webhook の `occurredAt` を受け取っても内部更新には使わない。

## 応募ステータス

`applied` → `document_passed` → `interview` → `offered`。どの時点でも `rejected` へ。ここでの **interview** は選考の面接段階であり、人事面接の練習資料という意味ではない。不正な飛び越し（例: `applied` → `interview`）は 409。

## webhook（pf-calendar → pf-talent-api）

- HTTP: `POST /webhooks/calendar`
- 必須ヘッダ: `X-Calendar-Event-Type: calendar.booking.confirmed`
- 必須本文: `calendar.booking.confirmed` エンベロープ（`id`, `type`, `occurredAt`, `data`）
- `data.externalRef`: いまは **job id**。pf-calendar の `event_type.externalRef` を応募へ紐付ける

対象応募があれば `200 { ok: true, matched: true, applicationId, status }`。無ければ `200 { ok: true, matched: false }`。ヘッダ不一致 / 本文不正は `400 invalid_request`。

## 検索と一覧

公開の `GET /v1/jobs` は published のみ。`q` は Postgres の全文検索と trigram 部分一致を OR する（日本語の途中一致を含む）。フィルタ無しは `created_at` 順。`q` があるときは関連度が先。OpenSearch は使わない。

下書きは企業向け `GET /v1/employers/:sub/jobs`。応募一覧は当事者の開発ヘッダ（または Bearer）が一致しないと 403。ゲスト画面は無い。Web は `?user=` 必須。

## 保存検索

候補者が条件を名前付きで保存し、`run` でいまの published 求人に対して同期再実行する。非同期ワーカーは無い。

## 面接枠

`GET /v1/applications/:id/interview-slots` は、応募が `document_passed` または `interview` のときだけ、pf-calendar の公開枠 API を返す。枠 UI は再実装しない。対応する event type が無ければ 404。範囲クエリは必須。

## 類似求人

`GET /v1/jobs/:id/similar` は `source: "recommend" | "fallback"` を返す。

- `RECOMMEND_API_URL` が設定され、pf-recommend の `/v1/similar-items?namespace=jobs` が成功し、かつスキル重なりがローカル順位と同等以上なら `recommend`
- 未接続・失敗・スキル重なりが明らかに劣る場合は **スキル重なりに閉じる**（`fallback`）。推薦結果を無理に採用しない

## ファセットと通報

`GET /v1/jobs/facets` は現在の検索条件に対する published の件数。通報は `POST /v1/reports`。一覧は open のみ。

## シード

`POST /v1/dev/seed` と起動時の空ストア投入。架空企業。実在企業名は使わない。
