# 基本設計書 - API設計

バージョン: 0.1  
作成日: 2025-12-15  
参照: 統合要件定義書 (統合要件定義書.md)

## 1. 目的
- 「AI活用ナレッジ共有サイト」 のバックエンド API 設計の基本方針を定義する。
- 主要エンドポイントとデータモデル、セキュリティ・非機能要件、運用要件の指針を示す。

## 2. 適用範囲
- RESTful API（/api/v1）設計を想定。MVPフェーズの実装方針を中心に記述する。

## 3. 設計原則
- Versioning: /api/v1 を基本。後方互換性を維持しつつ v2 で破壊的変更。
- 一貫したエラーフォーマットとステータスコード利用。
- JSON を主要ペイロード形式。Content-Type: application/json。
- セキュリティ最優先（TLS, JWT, input validation, RBAC）。

## 4. 認証・認可
- 認証方式: JWT (Bearer token)。短寿命アクセストークン + リフレッシュトークン。
- 新規登録: メールドメイン制限（@ginga.info） + ダブルオプトイン（確認リンク）。
- パスワード保存: bcrypt work factor >= 12。
- RBAC: Admin, User（必要に応じて Moderator 等追加）。

## 5. 共通事項
- Base URL: https://api.example.internal/api/v1
- 共通ヘッダ:
  - Authorization: Bearer <token>
  - Accept: application/json
  - Content-Type: application/json
- 共通応答フォーマット（成功）:
  - 200/201: { "data": ..., "meta": { ... } }
- 共通エラーフォーマット:
  - { "error": { "code": "string", "message": "string", "details": {...} } }

## 6. ページング・ソート・フィルタリング
- ページネーション: cursor または offset/limit。MVP は offset/limit をデフォルト。
  - query params: ?page=1&per_page=20
  - デフォルト per_page = 20, max = 100
- ソート: ?sort=created_at,-likes
- フィルタ: ?tags=ai,ml&author_id=...

## 7. レート制限・スロットリング
- デフォルト: 100 req/min per user（要検討）。管理 API は厳格化。
- レート超過時: 429 Too Many Requests + Retry-After header

## 8. エンドポイント一覧（要旨）
- Auth
  - POST /api/v1/auth/register — 登録（メール送信、ドメインチェック）
  - GET /api/v1/auth/confirm?token= — メール確認（アクティベーション）
  - POST /api/v1/auth/login — ログイン (email/password) -> access + refresh
  - POST /api/v1/auth/refresh — トークン更新
- Users
  - GET /api/v1/users/{id} — ユーザー情報取得（自分/管理者）
  - PUT /api/v1/users/{id} — ユーザー更新（権限変更多は管理者のみ）
- Knowledge (投稿)
  - POST /api/v1/knowledge — 作成 (draft/pending)
  - GET /api/v1/knowledge — 検索一覧（query, tags, author, status, pagination）
  - GET /api/v1/knowledge/{id} — 詳細
  - PUT /api/v1/knowledge/{id} — 編集（履歴保存）
  - GET /api/v1/knowledge/{id}/history — 編集履歴一覧取得（過去バージョン参照用）
  - DELETE /api/v1/knowledge/{id} — 論理削除
  - POST /api/v1/knowledge/{id}/submit — 公開申請 (status -> pending)
- Like / Reaction
  - POST /api/v1/knowledge/{id}/like — いいね (1ユーザー1回)
  - DELETE /api/v1/knowledge/{id}/like — いいね解除
- Comment
  - POST /api/v1/knowledge/{id}/comments — コメント作成（parent_comment_id optional）
  - GET /api/v1/knowledge/{id}/comments — コメント一覧（threaded）
  - PUT/DELETE /api/v1/comments/{id} — 編集/削除（権限制御）
- Tags
  - GET /api/v1/tags — タグ一覧取得（タグクラウド・検索フィルタ用）
- Attachment / Media
  - POST /api/v1/attachments — アップロード（multipart/form-data または事前署名）
  - GET /api/v1/attachments/{id} — ダウンロード（署名付きURL 推奨）
- Admin
  - GET /api/v1/admin/knowledge?status=pending — 承認待ち一覧
  - POST /api/v1/admin/knowledge/{id}/approve — 承認
  - POST /api/v1/admin/knowledge/{id}/reject — 却下（理由記録）
  - GET /api/v1/admin/auditlogs — 監査ログ検索

## 9. 主要 API の詳細（サンプル）

- POST /api/v1/auth/register
  - 説明: 社内ドメインでユーザー登録し確認メールを送る
  - Body:
    - { "name": "string", "email": "user@ginga.info", "password": "string" }
  - Validation:
    - email domain must end with @ginga.info
    - password complexity rules
  - Responses:
    - 201: { "data": { "id": "uuid", "email": "...", "status": "pending" } }
    - 400: invalid input
    - 409: email already exists

- POST /api/v1/auth/login
  - Body: { "email": "...", "password": "..." }
  - Responses:
    - 200: { "data": { "access_token": "...", "refresh_token": "...", "expires_in": 3600 } }
    - 401: invalid credentials

- POST /api/v1/knowledge
  - Auth: Bearer required
  - Body:
    - { "title": "string", "body": "markdown string", "tags": ["ai"], "status": "draft" }
  - Responses:
    - 201: created resource
    - 400: validation errors
  - Notes:
    - 保存時に編集履歴を断続的に保存（バージョニング）

- GET /api/v1/knowledge?query=...&tags=...&page=1&per_page=20
  - Auth: optional（公開/非公開ポリシーに準拠）
  - Responses:
    - 200: { "data": [ ... ], "meta": { "page":1, "per_page":20, "total":123 } }

## 10. データモデル（概要）
- User
  - id: UUID, name: string, email: string (unique), password_hash: string, role: enum, status: enum, created_at, updated_at
- Knowledge
  - id: UUID, title: string, body: text (markdown), author_id: UUID, status: enum(draft,pending,published,declined,archived), tags: array, created_at, updated_at
- Comment
  - id: UUID, knowledge_id: UUID, author_id: UUID, body: text, parent_comment_id: UUID|null, created_at
- Attachment
  - id: UUID, knowledge_id: UUID|null, filename: string, storage_path: string, size: int, content_type: string, created_at
- AuditLog
  - id: UUID, actor_id: UUID, action: string, target_id: UUID|null, details: json, created_at

## 11. エラーハンドリング（標準）
- HTTP ステータスを適切に使用:
  - 200 OK, 201 Created, 204 No Content
  - 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 429 Too Many Requests, 500 Internal Server Error
- エラー例:
  - 400: { "error": { "code": "INVALID_INPUT", "message": "title is required", "details": { "field":"title" } } }

## 12. セキュリティ要件（API側）
- TLS 1.2+（推奨 TLS 1.3）
- JWT の署名・検証（RS256 推奨）
- パスワードは bcrypt >= 12
- 入力検証（SQL/NoSQL インジェクション対策）、出力エスケープ（XSS対策）
- CSRF: ブラウザ向けAPIは適切な対策（SameSite cookie / CSRF token）
- ファイルアップロードの制限: 画像 10MB/file、添付 50MB/file。拡張子/コンテンツ検査、ウイルススキャン検討。
- ログにパスワードやトークンを残さない。

## 13. 非機能要件（API）
- レイテンシ目標: 検索 API p95 <= 1.5s（MVP 目標）
- 可用性: SLA 99.9% 目標
- バックアップ: DB 日次スナップショット保持 30日
- ロギング: 重要イベント（ログイン、権限変更、公開/却下）を監査ログとして保存

## 14. 運用・監視
- リクエスト/エラー率・レイテンシ・DBコネクション数をメトリクス収集（Prometheus/Grafana 等）
- 監査ログの検索性と保持ルールを確立
- アラート: エラーレート急増、CPU/メモリ高負荷、ディスク容量逼迫

## 15. テスト計画（概要）
- 単体テスト: 各ハンドラー・サービスのユニットテスト
- 統合テスト: DB・ストレージを使ったエンドツーエンドテスト
- セキュリティテスト: OWASP Top 10 を中心に脆弱性診断
- 負荷試験: ピーク同時リクエスト100件で主要指標測定

## 16. 拡張ポイント / 将来検討
- 検索のスケール: Elasticsearch 導入
- ファイルウイルススキャン、外部アイデンティティ連携（SSO）
- 多言語対応、全文検索の順位調整、推薦エンジン

## 17. 付録
- 用語集
- 変更履歴

変更履歴:
- 0.1 初版
