# AI駆動開発実践プロジェクト (ai-knowledge-share-site)

## 概要 (Overview)

このプロジェクトは、若手エンジニア3名がAI開発支援ツール（Cursor, VS Codeなど）を駆使してWebアプリケーションを開発する、3ヶ月間の実践プロジェクトです。

開発プロセスを通じて得られたAI活用のリアルな知見（実践的なプロンプト例、エラー解決事例など）を集約・共有するWebサイト（ナレッジ共有サイト）を構築することを目的としています。

## ✨ プロジェクトの目的
* AI駆動開発の具体的な方法論とノウハウの共有
* 開発生産性の向上とコード品質の改善
* 組織全体のAX（AI Transformation）推進への貢献

## 🛠️ 使用技術 (Tech Stack)

* **フロントエンド:** React or vue.js
* **バージョン管理:** Git / GitHub
* **タスク管理:** Jira
* **AI支援ツール:** VS Code + Github Copilot

---

## 🚀 ローカル環境での実行方法 (Getting Started)

1.  このリポジトリをクローンします。
    ```bash
    git clone git@github.com:MasatakaNakamura/proj-1sys-ax-2025.git
    ```

2.  アプリケーションディレクトリに移動します。
    ```bash
    cd app
    ```

3.  必要なパッケージをインストールします。
    ```bash
    npm install
    ```

4.  開発サーバーを起動します。
    ```bash
    npm start
    ```
    ブラウザで `http://localhost:3000` が開きます。

---

## 📂 ディレクトリ構成

このプロジェクトは、アプリケーションコードとドキュメントを単一のリポジトリで管理する「モノレポ」構成を採用しています。

```plaintext
/ (ai-knowledge-share-site)
|
|-- .github/
|   |-- workflows/
|       |-- ci.yml          # CI/CD ワークフロー定義 (将来用)
|
|-- app/                    # Reactアプリケーションのソースコード
|   |-- public/             # (React) 静的ファイル (index.html, favicon など)
|   |-- src/                # (React) ソースコードルート
|   |   |-- components/     # 共通コンポーネント
|   |   |-- pages/          # ページごとのコンポーネント
|   |   |-- ...             # その他 (hooks, styles, etc.)
|   |-- package.json        # アプリケーションの依存関係とスクリプト
|
|-- docs/                   # プロジェクト関連ドキュメント
|   |-- 01_planning/        # 企画・要件定義 (企画案.pptx など)
|   |-- 02_design/          # 設計書 (アーキテクチャ図, ワイヤーフレームなど)
|   |-- 03_knowledge/       # 成果物 (AI活用ナレッジ, プロンプト集など)
|   |-- 04_presentation/    # 最終成果発表会の資料
|
|-- .gitignore                # Gitの追跡対象外ファイル・フォルダを指定
|-- README.md                 # リポジトリの概要 (このファイル)
```
---

## ⚖️ プロジェクトルール (Rules)
開発スタイル: アジャイル開発

タスク管理: すべてのタスクは [Jiraボードへのリンク](https://masae53el.atlassian.net/jira/software/projects/AI/boards/34?atlOrigin=eyJpIjoiNzE0OTM1NDUzYzMwNDJkZmIyNTk0NTdlNTdjODBiZjciLCJwIjoiaiJ9) で管理します。

---
## ブランチ戦略:

main: 常にデプロイ可能な安定ブランチ。
develop: 開発のベースとなるブランチ。
feature/xxx: 各機能の開発ブランチ（developから切る）。

作業完了後は、develop へのプルリクエスト（PR）を作成してください。

---
## Slack通知:
CI/CDのビルドステータスや重要なイベントは、専用のSlackチャンネルに通知されます。
通知設定は `.github/workflows/slack-pr-comment-notification.yml` に記載されています。`