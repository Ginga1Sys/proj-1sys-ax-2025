# Copilot / AI アシスタント向け指示（プロジェクト：AIナレッジ共有サイト）

このファイルはリポジトリに対して GitHub Copilot や類似の AI 補助ツールが従うべきガイドラインを示します。

## 目的
- 開発を迅速に進めつつ、コード品質と一貫性を保つ。
- 生成コードは必ずレビューとテストを通すこと。

## 前提条件
- 出力言語は日本語（ドキュメントや画面文言も日本語優先）。
- フロントエンドの言語はNext.js (React, TypeScript)を使用。
- バックエンド（API）の言語はJava（Spring Boot）を使用。

## アプリ概要
- 社内ナレッジ共有プラットフォームを構築する。
- AI活用事例の集約と検索性の向上
- 社員間のナレッジ共有文化の醸成
- 業務効率化と品質向上

## ディレクトリ構成
- フロントエンド: `NaviAI-Front/app` 配下に画面資産を配置。ディレクトリ構成は下記の通りです。
  - `app/`
    - `pages/`
      - `login/`　# SCR-01、SCR-02
      - `dashboard/`　# SCR-03～SCR-11
        - `common_header.html`　# SCR-03～SCR-11の共通ヘッダー
        - `common_module.css`
      - `public-home/`　# SCR-12
        - `common_module.css`
        - `index.tsx`
    - `styles/` # 共通スタイル
      - `global.css`
      - `tokens.css`
      - `components/`
        - `card.module.css`
        - `header.module.css`
 - バックエンド: `NaviAI-Back/app/src/main` 配下に主要な API 実装を配置。以下は主要ソースと役割の概要です。
   - `app/src/main`
     - `java/`
       - `com/ginga/naviai/`
         - `NaviAiBackApplication.java`: Spring Boot アプリケーションのエントリポイント（`main` メソッド）。
         - `config/`
           - `AsyncRetryConfig.java`: 非同期実行とリトライ設定（`mailTaskExecutor` など）。
           - `SecurityConfig.java`: `BCryptPasswordEncoder` 等のセキュリティ設定。
         - `mail/`
           - `MailService.java`: メール送信の抽象インターフェース。
           - `SmtpMailService.java`: `MailService` 実装（`JavaMailSender`、`@Async`、`@Retryable`）。
         - `auth/`
           - `controller/`
             - `AuthController.java`: 認証関連の REST API（`/register`, `/login`, `/confirm` など）。
           - `dto/`
             - `UserResponse.java`: クライアントへ返すユーザー情報の DTO（id, username, email, displayName, createdAt）。
             - `RegisterRequest.java`: 登録リクエストの DTO（バリデーション注釈付）。
             - `LoginRequest.java`: ログインリクエスト DTO（`usernameOrEmail`, `password`）。
             - `LoginResponse.java`: ログイン成功時に返す DTO（`UserResponse`、`token`、`expiresIn`）。
           - `entity/`
             - `User.java`: `users` テーブルに対応する JPA エンティティ。
             - `ConfirmationToken.java`: メール確認用トークンエンティティ。
           - `exception/`
             - `DuplicateResourceException.java`: 重複リソース時の例外。
             - `InvalidCredentialsException.java`: ログイン失敗時の例外。
             - `AccountNotEnabledException.java`: 未有効アカウントの例外。
             - `GlobalExceptionHandler.java`: `@ControllerAdvice` による共通例外ハンドリング（バリデーションエラーは 400、重複は 409、認証失敗や未有効は適切なステータスを返す）。
           - `repository/`
             - `UserRepository.java`, `ConfirmationTokenRepository.java` などの `JpaRepository`。
           - `service/`
             - `AuthService.java`, `AuthServiceImpl.java`（`register`, `login` の実装）、`ConfirmationTokenService.java` など。
           - `validation/`
             - `StrongPassword.java`, `StrongPasswordValidator.java`（カスタムバリデータ）。
     - `resources/`
       - `application.properties`: H2 インメモリ DB 等の設定。
       - `db/`
         - `migration/`
           - `V1__create_users_table.sql`: `users` テーブル作成用マイグレーションSQL（id, username, email, password_hash, display_name, enabled, created_at, updated_at を定義）。

## 要件定義書
- `proj-1sys-ax-2025/docs/00_personal/nishizawa/統合要件定義書.md`

## 基本設計書
- `proj-1sys-ax-2025/docs/00_personal/nishizawa/基本設計書/`
  - `画面イメージ図/`
    - `SCR-01_ログイン画面_イメージ図.svg`
    - `SCR-02_会員登録_イメージ図.svg`
    - `SCR-03_ダッシュボード_イメージ図.svg`
    - `SCR-04_検索結果一覧_イメージ図.svg`
    - `SCR-05_投稿一覧（マイ投稿）_イメージ図.svg`
    - `SCR-06_記事詳細画面_イメージ図.svg`
    - `SCR-07_記事投稿・編集画面_イメージ図.svg`
    - `SCR-08_コメントスレッド_イメージ図.svg`
    - `SCR-09_プロフィール_マイページ_イメージ図.svg`
    - `SCR-10_管理者パネル_イメージ図.svg`
    - `SCR-11_承認待ち一覧_Review_イメージ図.svg`
    - `SCR-12_公開トップ（未ログイン）_イメージ図.svg`
  - `基本設計_API.md`
  - `基本設計_DB設計.md`
  - `基本設計_画面遷移図.md`

## テストとローカル検証
- 変更時は関連するテストを追加・更新し、テストが通ることを確認するコマンドを提示する。
- フロントエンドでは見た目に影響する場合、スクリーンショットや確認手順を記載する。

## レビュー (必須)
- ファイルを新規作成した、またはファイルの中身を修正した場合は、次の作業選択肢を提示せず、まず生成内容や修正内容のレビューを実施するよう促してください。レビューで「問題ない」との明確な承認を受け取った後に、次の作業を提示してください。

## ドキュメント
- API や公共インターフェースを変更する場合は、対応するドキュメント（README や docs 配下）を更新すること。

## プロンプト例（Copilot に渡すとき）
1. 「このリポジトリは AI ナレッジ共有サイトです。既存の TypeScript/React のスタイルに合わせて、次のコンポーネントを実装してください: <要件>。単体テストと簡単な使用例も追加してください。」
2. 「この変更は既存 API に影響します。互換性を保つための移行手順と、既存テストを壊さない方法を提案してください。」

## 不明点がある場合
- 要件が不明確な場合は、必ず質問を投げて確認を行ってください（仕様の仮定で実装を進めない）。

---
プロジェクト固有の追加ルールや補助が必要であれば、リポジトリのメンテナーに連絡してください。
