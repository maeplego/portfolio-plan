# 図表

| 項目 | 値 |
| --- | --- |
| プロダクト | 予約カレンダー [pf-calendar](https://github.com/maeplego/pf-calendar) |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |
| 記法 | Mermaid。ユースケースは UML 楕円の代替としてフロー |

詳細な文章は仕様・設計を参照する。図は構造の索引。

## 1. ユースケース

```mermaid
flowchart LR
  subgraph actors [アクター]
    Host[ホスト]
    Guest[ゲスト]
    Talent[求人 API]
  end

  subgraph uc [予約カレンダー]
    UC1[イベントタイプと空きルールを定義する]
    UC2[例外日をブロックする]
    UC3[空き枠を Instant で列挙する]
    UC4[オファー中の枠を予約する]
    UC5[自分の予約一覧を見る]
    UC6[キャンセルする]
    UC7[面談枠を求人に紐づける]
  end

  Host --> UC1
  Host --> UC2
  Host --> UC3
  Host --> UC5
  Guest --> UC3
  Guest --> UC4
  Guest --> UC6
  Talent --> UC7
  UC4 --> UC3
```

求人側の webhook 受信（`POST /webhooks/calendar`）とカレンダー側の内部 API・outbox 配信は現行。

## 2. 画面遷移（実装済み）

```mermaid
flowchart TB
  subgraph guestUi [ゲスト]
    G1[公開 URL /book/:slug]
    G2[週または日を選ぶ]
    G3[starts をゲスト TZ で表示]
    G4[氏名メールで確定]
    G5[完了_ICS とキャンセルリンク]
    G6[/cancel?token=]
    G1 --> G2 --> G3 --> G4 --> G5
    G5 --> G6
  end

  subgraph hostUi [ホスト]
    H0[/login OIDC 任意]
    H1[/host ダッシュボード]
    H2[イベントタイプ設定]
    H0 --> H1
    H1 --> H2
  end

  subgraph api [API]
    A1[GET /public/:slug/slots]
    A2[POST /public/:slug/book]
    A3[GET /v1/event-types]
    A4[POST /public/bookings/cancel]
  end

  G3 --> A1
  G4 --> A2
  G6 --> A4
  H1 --> A3
```

ゲスト TZ セレクタは G3 の表示だけを変える。A1 の `starts` は変えない。

## 3. シーケンス: 枠一覧

```mermaid
sequenceDiagram
  participant C as クライアント
  participant API as apps/api
  participant Eng as slot-engine
  participant S as Store

  C->>API: GET /public/:slug/slots?rangeStart&rangeEnd
  API->>S: getEventTypeBySlug
  API->>S: listConfirmedBookings
  API->>API: clock.nowIso
  API->>Eng: generateSlots(host TZ ルール, 予約, range, now)
  Eng-->>API: Instant[]
  API-->>C: starts, hostTimeZone（PII なし）
```

## 4. シーケンス: 予約成功（単独）

```mermaid
sequenceDiagram
  participant C as ゲスト
  participant API as apps/api
  participant Eng as isOfferedStart
  participant S as Store

  C->>API: POST /public/:slug/book slotStart Instant
  API->>S: findBookingByIdempotency
  alt 同じキー・同じ内容
    API-->>C: 200 既存（cancelToken なし）
  else キーなし
    API->>S: listConfirmedBookings
    API->>Eng: ホスト現地その日を再計算
    alt オファー外
      API-->>C: 409 slot_unavailable
    else オファー中
      API->>S: createBooking
      S-->>API: created
      API-->>C: 201 と cancelToken 平文
    end
  end
```

## 5. シーケンス: 同時 2 リクエスト（TOCTOU）

Check は両方 true。Use（INSERT）で片方だけ残る。Memory と Postgres は Store の別実装。

```mermaid
sequenceDiagram
  participant A as ゲストA
  participant B as ゲストB
  participant API as apps/api
  participant Eng as isOfferedStart
  participant S as Store第2段

  Note over A,S: T0 枠 S は空
  par T1 同時 POST
    A->>API: book slotStart=S
    B->>API: book slotStart=S
  end
  Note over API: T3 両者 listConfirmedBookings = []
  par T4 Time of Check
    API->>Eng: isOfferedStart(A, [])
    Eng-->>API: true
    API->>Eng: isOfferedStart(B, [])
    Eng-->>API: true
  end
  Note over API,S: T6 Time of Use
  par createBooking
    API->>S: INSERT A
    S-->>API: OK
    API->>S: INSERT B
    S-->>API: 重なり拒否
  end
  API-->>A: 201 または 409
  API-->>B: 残り一方
  Note over A,B: 集合は 201 と 409。確定は 1 件
```

Postgres なら拒否は `EXCLUDE USING gist`（23P01）。Memory なら `overlapsConfirmed`（同じ関数内に await が無く、後発が見るときには先発が push 済み）。

## 6. 予約の状態

```mermaid
stateDiagram-v2
  [*] --> confirmed: POST book 201
  confirmed --> confirmed: 同一冪等キー再送 200
  confirmed --> cancelled: トークンキャンセル
  cancelled --> [*]
```

exclusion は `confirmed` だけに掛ける。cancelled 同士や cancelled と confirmed は重ならない。

## 7. ER（現行テーブル）

```mermaid
erDiagram
  HOSTS ||--o{ EVENT_TYPES : owns
  EVENT_TYPES ||--o{ AVAILABILITY_RULES : has
  EVENT_TYPES ||--o{ DATE_OVERRIDES : has
  EVENT_TYPES ||--o{ BOOKINGS : receives

  HOSTS {
    text id PK
    text sub UK
  }
  EVENT_TYPES {
    text id PK
    text host_id FK
    text slug UK
    int duration_minutes
    int buffer_minutes
    int min_notice_minutes
    text host_time_zone
  }
  AVAILABILITY_RULES {
    text id PK
    text event_type_id FK
    smallint day_of_week
    text start_local
    text end_local
  }
  DATE_OVERRIDES {
    text id PK
    text event_type_id FK
    date on_date
    boolean blocked
  }
  BOOKINGS {
    text id PK
    text event_type_id FK
    timestamptz start_at
    timestamptz end_at
    tstzrange during
    text guest_email
    text guest_time_zone
    text status
    text idempotency_key
    text cancel_token_hash
  }
```

`during` は生成列。ユニークは `(event_type_id, idempotency_key)`。重なり禁止は gist exclusion。
