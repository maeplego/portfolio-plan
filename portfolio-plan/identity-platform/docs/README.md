# 認証基盤の書類

実装は [pf-identity](https://github.com/maeplego/pf-identity) です。このフォルダは、何を満たすか・外からどう見えるか・中をどう守るか・何をテストするかを分けて書いています。文書と実装が違うときは、コードとテストを優先してください。

メール検証、パスキー、SAML はありません。

| ファイル | 内容 |
| --- | --- |
| [01-requirements.md](01-requirements.md) | 目的、含む / 含まない、受け入れ |
| [02-specification.md](02-specification.md) | ログインとトークンの振る舞い |
| [03-design.md](03-design.md) | セッション、ハッシュ、鍵 |
| [04-test-spec.md](04-test-spec.md) | テストの観点 |
| [05-api.md](05-api.md) | OpenID Connect のエンドポイント |
| [06-diagrams.md](06-diagrams.md) | 図表 |
