# Slack PR コメント通知の設定手順

このドキュメントでは、GitHub PRにコメントが投稿された際にSlackへ自動通知する機能の設定方法を説明します。

## 概要

GitHub ActionsとSlack Incoming Webhookを使用して、以下のイベントが発生した際にSlackへ通知を送信します：

- PRへの一般コメント（issue_comment）
- コードレビューコメント（pull_request_review_comment）
- プルリクエストレビューの投稿（pull_request_review）

## 前提条件

- GitHubリポジトリへの管理者権限
- Slackワークスペースへのアプリ追加権限

## 設定手順

### 1. Slack Incoming Webhookの作成

1. Slackワークスペースにログインします

2. [Slack App Directory](https://slack.com/apps) にアクセスし、「Incoming Webhooks」を検索します

3. 「Add to Slack」をクリックします

4. 通知を投稿するチャンネルを選択します
   - 例：`#github-notifications` や `#dev-team` など

5. 「Add Incoming WebHooks integration」をクリックします

6. **Webhook URL**をコピーします
   - URLは `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX` のような形式です
   - ⚠️ このURLは秘密情報として扱ってください

7. （オプション）以下の設定をカスタマイズできます：
   - 名前：`GitHub PR Notifications`
   - アイコン：GitHubのロゴなど
   - 説明：`PRコメントの自動通知`

8. 「Save Settings」をクリックします

### 2. GitHub Secretsの設定

1. GitHubリポジトリのページに移動します

2. **Settings** タブをクリックします

3. 左サイドバーから **Secrets and variables** > **Actions** をクリックします

4. **New repository secret** をクリックします

5. 以下の情報を入力します：
   - **Name**: `SLACK_WEBHOOK_URL`
   - **Secret**: 先ほどコピーしたSlack Webhook URL

6. **Add secret** をクリックします

### 3. GitHub Actionsワークフローの確認

以下のワークフローファイルが既に作成されています：

```
.github/workflows/slack-pr-comment-notification.yml
```

このワークフローは自動的に以下の処理を行います：

- PRにコメントが投稿されると発動
- コメント情報を整形
- Slackに通知を送信

### 4. 動作確認

1. テスト用のPRを作成します

2. PRにコメントを投稿します

3. 設定したSlackチャンネルに通知が届くことを確認します

通知には以下の情報が含まれます：
- PR番号とタイトル
- コメント投稿者
- コメント内容（最初の100文字）
- コメントへの直接リンク

## 通知される内容

### Slackメッセージの例

```
💬 新しいPRコメント

PR: #123 TypeScript導入の提案
投稿者: nakamura-san

コメント:
この実装は良いですね。ただし、型定義をもう少し厳密にした方が...

[コメントを見る] ボタン
```

## トラブルシューティング

### 通知が届かない場合

1. **GitHub Secretsの確認**
   - `SLACK_WEBHOOK_URL`が正しく設定されているか確認
   - Webhook URLに余計なスペースが含まれていないか確認

2. **GitHub Actionsの実行ログを確認**
   - リポジトリの「Actions」タブで実行ログを確認
   - エラーメッセージがあれば内容を確認

3. **Webhook URLの有効性確認**
   - Slackの設定画面でWebhookが有効になっているか確認
   - 必要に応じてWebhook URLを再生成

4. **ワークフローの権限確認**
   - リポジトリの Settings > Actions > General で、
     「Read and write permissions」が有効になっているか確認

### よくある質問

**Q: 特定の人のコメントのみ通知することはできますか？**

A: はい。ワークフローファイルの条件を修正することで可能です。詳しくはチームの担当者にお問い合わせください。

**Q: 通知メッセージの内容をカスタマイズできますか？**

A: はい。`.github/workflows/slack-pr-comment-notification.yml`ファイルのペイロード部分を編集することでカスタマイズできます。

**Q: 複数のSlackチャンネルに通知できますか？**

A: 複数のWebhook URLを設定し、ワークフローで複数回curlコマンドを実行することで可能です。

## 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
- [GitHub Webhooks Events](https://docs.github.com/en/webhooks-and-events/webhooks/webhook-events-and-payloads)

## 更新履歴

- 2025-11-13: 初版作成
