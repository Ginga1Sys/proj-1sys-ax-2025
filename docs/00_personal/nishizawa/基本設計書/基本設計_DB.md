# DB設計（基本設計書） — 基本設計_DB.md

## 1. ドキュメント情報
- ドキュメント名：DB設計（基本設計書）
- バージョン：1.0
- 作成日：2025-12-06
- 作成者：西澤
- 対応システム：AI活用ナレッジ共有サイト
- 対象フェーズ：基本設計

## 2. 目的
- 統合要件定義書に基づき、RDBMS（PostgreSQL）上の論理/物理テーブル設計、インデックス、制約、運用（バックアップ/監視/セキュリティ）方針を確定する。

## 3. 適用範囲・前提条件
- 対象データ: ユーザー、投稿（Knowledge）、コメント、添付、タグ、いいね、監査ログ、リビジョン
- RDBMS: PostgreSQL 13+
- 文字コード: UTF-8
- OS: Linux（Dockerコンテナ想定）

## 4. 用語定義
- Knowledge = 投稿 / Article
- User = 社員アカウント（社内ドメイン制限）
- Revision = 投稿の編集履歴
- AuditLog = 重要操作の記録

## 5. 非機能要件（DB観点）
- 目標性能: 同時セッションピーク 100、RPS（API）目標 200 RPS（水平スケール前提）
- レスポンスタイム: 検索 API p95 <= 1.5s（MVP: DB検索）
- 容量想定（初期）:
  - ユーザー: 1,000
  - 投稿: 50,000
  - コメント: 200,000
  - 添付合計: 数百GB（S3保管、DBにはメタのみ）
- 可用性: SLA 99.9%、日次バックアップ、保持30日（将来365日）
- RTO/RPO: RTO <= 2時間、RPO <= 1時間（差分/増分バックアップ組合せ）

## 6. 概要設計（論理設計）
- エンティティ: User, Knowledge, KnowledgeRevision, Comment, Attachment, Tag, KnowledgeTag, Like, AuditLog
- ER図: （統合要件のER図に準拠）
- 関係: User(1) - Knowledge(N), Knowledge(1) - Comment(N), Knowledge(1) - Attachment(N), Knowledge(N) - Tag(N) via KnowledgeTag

## 7. テーブル設計（物理設計）

テーブル: users
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | ユーザーID |
|2| name | VARCHAR(200) | NO | - | - | 表示名 |
|3| email | VARCHAR(320) | NO | UNI | - | 社内ドメイン制限 (@ginga.info) |
|4| password_hash | VARCHAR(255) | NO | - | - | bcryptハッシュ |
|5| role | VARCHAR(50) | NO | - | 'user' | RBAC |
|6| is_active | BOOLEAN | NO | - | false | メール確認後 true |
|7| created_at | TIMESTAMP WITH TIME ZONE | NO | - | now() | 作成日時 |
|8| updated_at | TIMESTAMP WITH TIME ZONE | NO | - | now() | 更新日時 |

インデックス: UNIQUE(email), idx_users_role_created_at(role, created_at)

テーブル: knowledge
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | 投稿ID |
|2| author_id | UUID | NO | FK -> users.id | - | 著者 |
|3| title | VARCHAR(500) | NO | - | '' | タイトル |
|4| body | TEXT | YES | - | NULL | 本文（Markdown） |
|5| status | VARCHAR(20) | NO | - | 'draft' | draft/pending/published/declined/archived |
|6| is_deleted | BOOLEAN | NO | - | false | 論理削除 |
|7| created_at | TIMESTAMP WITH TIME ZONE | NO | - | now() | 作成日時 |
|8| updated_at | TIMESTAMP WITH TIME ZONE | NO | - | now() | 更新日時 |
|9| published_at | TIMESTAMP WITH TIME ZONE | YES | - | NULL | 公開日時 |

インデックス: idx_knowledge_author_created(author_id, created_at), idx_knowledge_status_published(status, published_at), GIN(fulltext) on (to_tsvector('japanese', title || ' ' || body))

テーブル: knowledge_revision
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | 編集履歴ID |
|2| knowledge_id | UUID | NO | FK -> knowledge.id | - | 対象投稿 |
|3| editor_id | UUID | YES | FK -> users.id | - | 編集者 |
|4| title | VARCHAR(500) | YES | - | NULL | 編集時タイトル |
|5| body | TEXT | YES | - | NULL | 編集時本文 |
|6| diff_summary | TEXT | YES | - | NULL | 差分要約 |
|7| created_at | TIMESTAMPTZ | NO | - | now() | 作成日時 |

インデックス: idx_knowledge_revision_knowledge(knowledge_id, created_at)

テーブル: comment
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | コメントID |
|2| knowledge_id | UUID | NO | FK -> knowledge.id | - | 対象投稿 |
|3| author_id | UUID | YES | FK -> users.id | - | コメント投稿者 |
|4| body | TEXT | NO | - | - | コメント本文 |
|5| parent_comment_id | UUID | YES | FK -> comment.id | NULL | 返信先コメント |
|6| is_deleted | BOOLEAN | NO | - | false | 論理削除フラグ |
|7| created_at | TIMESTAMPTZ | NO | - | now() | 作成日時 |

インデックス: idx_comment_knowledge(knowledge_id, created_at), idx_comment_author(author_id)

テーブル: attachment
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | 添付ファイルID |
|2| knowledge_id | UUID | YES | FK -> knowledge.id | NULL | 関連投稿 |
|3| filename | TEXT | NO | - | - | 元ファイル名 |
|4| content_type | VARCHAR(100) | YES | - | NULL | MIMEタイプ |
|5| size_bytes | BIGINT | YES | - | NULL | ファイルサイズ |
|6| storage_path | TEXT | NO | - | - | ストレージ格納パス（S3等） |
|7| uploaded_at | TIMESTAMPTZ | NO | - | now() | アップロード日時 |

インデックス: idx_attachment_knowledge(knowledge_id)

テーブル: tag
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | タグID |
|2| name | VARCHAR(100) | NO | UNI | - | タグ名（ユニーク） |
|3| created_at | TIMESTAMPTZ | NO | - | now() | 作成日時 |

インデックス/UNIQUE: UNIQUE(name), idx_tag_created_at(created_at)

テーブル: knowledge_tag (many-to-many)
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| knowledge_id | UUID | NO | FK -> knowledge.id | - | 投稿ID |
|2| tag_id | UUID | NO | FK -> tag.id | - | タグID |

主キー: (knowledge_id, tag_id)  
インデックス: PK により検索最適化。必要に応じて idx_kntg_tag(tag_id) を追加。

テーブル: "like" (いいね)
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | いいねID |
|2| knowledge_id | UUID | NO | FK -> knowledge.id | - | 対象投稿 |
|3| user_id | UUID | NO | FK -> users.id | - | いいね実施者 |
|4| created_at | TIMESTAMPTZ | NO | - | now() | 作成日時 |

制約/UNIQUE: UNIQUE(knowledge_id, user_id)  
インデックス: idx_like_knowledge(knowledge_id), idx_like_user(user_id)

テーブル: audit_log
| No | カラム名 | 型 | NULL許可 | PK/FK | デフォルト | 説明 |
|---:|---|---|---:|---|---|---|
|1| id | UUID | NO | PK | gen_random_uuid() | ログID |
|2| actor_id | UUID | YES | FK -> users.id | NULL | 操作者 |
|3| action | VARCHAR(100) | NO | - | - | 操作名 |
|4| target_type | VARCHAR(50) | YES | - | NULL | 対象種別 |
|5| target_id | UUID | YES | - | NULL | 対象ID |
|6| detail | JSONB | YES | - | NULL | 詳細情報 |
|7| created_at | TIMESTAMPTZ | NO | - | now() | 記録日時 |

インデックス: idx_audit_log_actor_created(actor_id, created_at), 必要に応じて GIN インデックス on detail

参照整合性:
- 外部キーは基本 ON DELETE CASCADE（一部: users->knowledge は履歴保持のため制約設計に注意。運用ポリシーで決定）

NULL/デフォルト方針:
- 必須は NOT NULL、可選項目は NULL 許容。論理削除はフラグで管理。

## 8. シーケンス・自動採番
- 主キーは UUID を利用（pgcrypto の gen_random_uuid() または uuid-ossp）。数値シーケンスは使用しない想定。必要時に BIGSERIAL を検討。

## 9. 物理チューニング方針
- インデックス: 検索頻度の高いカラム（author_id, status, created_at, tags, fulltext）に複合/GINインデックスを配置。
- フルテキスト: PostgreSQL の tsvector + GIN を MVP で採用（日本語辞書設定を検討）。将来的に Elasticsearch 移行を想定。
- 大容量対策: 古い履歴やログは別テーブル/アーカイブ化。添付ファイルはオブジェクトストレージへ保管。
- VACUUM/ANALYZE の定期実行、Autovacuum チューニング。

## 10. バックアップ・リカバリ設計
- バックアップ方式: 日次フル + 1時間毎の差分/WALアーカイブ
- 保存先: オフサイトS3互換ストレージ、保持期間30日（将来365日）
- リストア手順: 最新フルを復元 -> WAL適用 -> アプリ接続確認
- テスト: 月次リストア検証を実施

## 11. データ移行・初期投入設計
- 初期データ: 管理者アカウント、数件のサンプル投稿・タグを投入
- 手順: ETLスクリプト（Node.js）で CSV/JSON をインポート。整合性チェックリストを実行（外部キー、ユニーク、ドメイン制約）

## 12. セキュリティ設計
- DB接続: TLS 必須、DBユーザーは最小権限で運用
- 暗号化: 静止データはストレージ側で暗号化、機微データ（パスワード）はハッシュのみ保存（bcrypt work factor >= 12）
- ログ監査: 重要操作（ログイン、権限変更、承認）を audit_log に記録・30日保持
- SQLインジェクション対策: プレースホルダ / ORM を使用

## 13. 運用監視設計
- 監視項目: DB接続数、遅延（99/95%）、CPU/メモリ、ディスク使用率、Autovacuum遅延、WALサイズ
- アラート基準: 接続数 > 80% of max, ディスク使用率 > 80%, p95クエリ時間閾値超過
- 対応フロー: アラート -> オンコール対応 -> インシデント記録

## 14. テスト観点
- 単体: 制約・外部キー・NOT NULL・ユニークの検証
- 結合: API経由でのデータ整合性（投稿作成->コメント->添付）
- 性能: 検索API p95 <= 1.5s（テスト条件を明示）、負荷試験 100 同時セッション
- リカバリ: 定期的なリストアテスト

## 15. 命名規則
- テーブル: lower_snake_case（users, knowledge, comment, attachment, tag, knowledge_tag, audit_log）
- PK: id
- FK: <referencing>_id
- インデックス: idx_<table>_<cols>、idx_gin_<table>_<col>（GIN インデックス）
- 制約: fk_<from>_<to>

## 16. サンプルDDL（PostgreSQL, 簡易）
```sql
-- filepath: d:\AI駆動開発デモ\proj-1sys-ax-2025\docs\00_personal\nishizawa\基本設計書\基本設計_DB.md
-- 使用拡張: pgcrypto または uuid-ossp
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(200) NOT NULL,
  email VARCHAR(320) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE knowledge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  title VARCHAR(500) NOT NULL DEFAULT '',
  body TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'draft',
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ
);

CREATE TABLE knowledge_revision (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  knowledge_id UUID NOT NULL REFERENCES knowledge(id) ON DELETE CASCADE,
  editor_id UUID REFERENCES users(id),
  title VARCHAR(500),
  body TEXT,
  diff_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE comment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  knowledge_id UUID NOT NULL REFERENCES knowledge(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id),
  body TEXT NOT NULL,
  parent_comment_id UUID REFERENCES comment(id) ON DELETE SET NULL,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE attachment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  knowledge_id UUID REFERENCES knowledge(id) ON DELETE CASCADE,
  filename TEXT NOT NULL,
  content_type VARCHAR(100),
  size_bytes BIGINT,
  storage_path TEXT NOT NULL,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tag (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE knowledge_tag (
  knowledge_id UUID NOT NULL REFERENCES knowledge(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tag(id) ON DELETE CASCADE,
  PRIMARY KEY (knowledge_id, tag_id)
);

CREATE TABLE "like" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  knowledge_id UUID NOT NULL REFERENCES knowledge(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (knowledge_id, user_id)
);

CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID,
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50),
  target_id UUID,
  detail JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- インデックス
CREATE INDEX idx_knowledge_author_created ON knowledge (author_id, created_at);
CREATE INDEX idx_knowledge_status_published ON knowledge (status, published_at);
CREATE INDEX idx_users_role_created_at ON users (role, created_at);

-- 日本語対応のフルテキスト列とGINインデックス（例）
ALTER TABLE knowledge ADD COLUMN ts_fulltext tsvector;
CREATE INDEX idx_gin_knowledge_fulltext ON knowledge USING GIN (ts_fulltext);

-- トリガー/関数で ts_fulltext を更新する（実装側でセット）
```

## 17. 付録
- ER図ファイル: docs/00_personal/nagumo に配置済みファイル参照
- 参考資料: PostgreSQL ドキュメント、OWASP、社内運用ガイド
- 変更履歴: 本書初版

