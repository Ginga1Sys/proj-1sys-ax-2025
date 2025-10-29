#!/bin/bash
# 提案されたリポジトリ構成を作成するシェルスクリプト

echo "プロジェクトのディレクトリ構成を作成しています..."

# メインディレクトリの作成
# -p オプションで、親ディレクトリが存在しない場合も合わせて作成します
mkdir -p .github/workflows
mkdir -p app/public
mkdir -p app/src/components
mkdir -p app/src/pages
mkdir -p docs/01_planning
mkdir -p docs/02_design
mkdir -p docs/03_knowledge
mkdir -p docs/04_presentation

echo "ディレクトリを作成しました。"

# プレースホルダーファイルの作成
# (touchコマンドで空のファイルを作成します)
touch .github/workflows/ci.yml
touch app/package.json
touch docs/01_planning/.gitkeep
touch docs/02_design/architecture.md
touch docs/03_knowledge/prompt_examples.md
touch docs/03_knowledge/error_solving_tips.md
touch docs/04_presentation/.gitkeep
touch .gitignore
touch README.md

echo "プレースホルダーファイルを作成しました。"
echo ""
echo "ファイル構造の作成が完了しました。"
echo "------------------------------------------------"
echo "次のステップ:"
echo "1. 'app/' ディレクトリにReactのソースコードを配置してください。"
echo "   (例: 'npx create-react-app app' または既存のコードを移動)"
echo "2. 'docs/01_planning/' に企画書(AI駆動チーム開発企画案.pptx)を配置してください。"
echo "   (現在は空のディレクトリをGit管理するため .gitkeep を置いています)"
echo "3. 'docs/04_presentation/' にも最終発表資料を配置してください。"
echo "4. 'README.md' と '.gitignore' の内容を編集してください。"

