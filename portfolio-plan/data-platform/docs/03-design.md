# 内部設計書

| 項目 | 値 |
| --- | --- |
| プロダクト | data-platform（GitHub: [pf-data](https://github.com/maeplego/pf-data)） |
| 最終更新 | 2026-08-19 |
| 実装との関係 | この文書と実装が違うときは、製品リポジトリのコードとテストを優先する |

## 構成

```
orchestrate/   Dagster
transform/     dbt-core
ingest/        MinIO と CSV 検証
seeds/         架空 CSV と expected_kpi.json
bi/            marts 向け SQL。Metabase は Compose profile bi
deploy/        Postgres 16、MinIO、pipeline、dagster
```

整数円。mart 粒度は `transform/manual/mart_shape.sql` と pytest / DuckDB が一致する。dbt mart テスト失敗時のテーブルスワップは未実装。CSV ゲートが昨日の mart を守る。

## 実行記録

`ops.job_runs` に行数と `failure_reason` を残す。Dagster UI（localhost:3013）はグラフ表示。一回実行の Compose サービス `pipeline` は成功 0 / 失敗 1 で終わる。

## BI

Metabase イメージは `deploy/compose.yaml` の `profiles: ["bi"]`。資格情報はコミットしない。接続先は Compose ネットワークの `postgres`、DB `data`、スキーマ `marts`。

## 他製品

[pf-commerce](https://github.com/maeplego/pf-commerce) / [pf-talent-api](https://github.com/maeplego/pf-talent-api) の本番エクスポートをソースにしたことにしない。コネクタは未実装。
