#!/bin/bash

# タスクファイルから GitHub Issue を作成するスクリプト
#
# 使い方:
#   ./scripts/create-issue-from-task.sh <task-id>
#
# 例:
#   ./scripts/create-issue-from-task.sh TASK-001
#   ./scripts/create-issue-from-task.sh TASK-001-auth-login

set -e

# 引数チェック
if [ -z "$1" ]; then
  echo "エラー: タスクIDを指定してください"
  echo "使い方: $0 <task-id>"
  echo ""
  echo "例:"
  echo "  $0 TASK-001"
  echo "  $0 TASK-001-auth-login"
  exit 1
fi

TASK_ID=$1

# GitHub CLI の確認
if ! command -v gh &> /dev/null; then
  echo "エラー: GitHub CLI (gh) がインストールされていません"
  echo "インストール方法: https://cli.github.com/"
  exit 1
fi

# タスクファイルを検索
TASK_FILE=""
for dir in ".claude/tasks/backlog" ".claude/tasks/in-progress" ".claude/tasks/review"; do
  if [ -f "${dir}/${TASK_ID}.md" ]; then
    TASK_FILE="${dir}/${TASK_ID}.md"
    break
  fi
  # サブディレクトリも検索（in-progress/[instance-name]/）
  for subfile in ${dir}/*/${TASK_ID}.md 2>/dev/null; do
    if [ -f "$subfile" ]; then
      TASK_FILE="$subfile"
      break 2
    fi
  done
done

if [ -z "$TASK_FILE" ]; then
  echo "エラー: タスクファイル '${TASK_ID}.md' が見つかりません"
  echo "検索パス:"
  echo "  - .claude/tasks/backlog/"
  echo "  - .claude/tasks/in-progress/"
  echo "  - .claude/tasks/review/"
  exit 1
fi

echo "📄 タスクファイルを検出: ${TASK_FILE}"

# タスクファイルからタイトルを抽出（最初の # で始まる行）
TASK_TITLE=$(grep -m 1 "^# " "$TASK_FILE" | sed 's/^# //')

if [ -z "$TASK_TITLE" ]; then
  TASK_TITLE="${TASK_ID}"
fi

# 既存の Issue 番号をチェック
EXISTING_ISSUE=$(grep -oP '(?<=GitHub Issue.*#)\d+' "$TASK_FILE" 2>/dev/null | head -1 || echo "")

if [ -n "$EXISTING_ISSUE" ]; then
  echo "⚠️  このタスクは既に Issue #${EXISTING_ISSUE} に紐付いています"
  echo "🔗 確認: gh issue view ${EXISTING_ISSUE}"
  exit 0
fi

# タスクファイルの内容を読み取り
TASK_BODY=$(cat "$TASK_FILE")

# ラベルを決定（タイトルから推測）
LABELS="status: backlog"
if echo "$TASK_TITLE" | grep -qi "feature\|feat\|機能"; then
  LABELS="${LABELS},feature"
elif echo "$TASK_TITLE" | grep -qi "bug\|fix\|バグ\|修正"; then
  LABELS="${LABELS},bug"
elif echo "$TASK_TITLE" | grep -qi "refactor\|リファクタ"; then
  LABELS="${LABELS},refactor"
elif echo "$TASK_TITLE" | grep -qi "doc\|ドキュメント"; then
  LABELS="${LABELS},docs"
elif echo "$TASK_TITLE" | grep -qi "test\|テスト"; then
  LABELS="${LABELS},test"
else
  LABELS="${LABELS},task"
fi

echo "🏷️  ラベル: ${LABELS}"
echo "📝 タイトル: ${TASK_TITLE}"
echo ""
echo "🚀 GitHub Issue を作成中..."

# Issue を作成
ISSUE_URL=$(gh issue create \
  --title "${TASK_TITLE}" \
  --label "${LABELS}" \
  --body "${TASK_BODY}" \
  2>&1)

# Issue 番号を抽出
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oP '(?<=issues/)\d+' || echo "")

if [ -z "$ISSUE_NUMBER" ]; then
  echo "エラー: Issue の作成に失敗しました"
  echo "$ISSUE_URL"
  exit 1
fi

echo "✅ Issue #${ISSUE_NUMBER} を作成しました"
echo "🔗 URL: ${ISSUE_URL}"

# タスクファイルに Issue 番号を追記
echo ""
echo "📝 タスクファイルに Issue 番号を追記中..."

# 既存の「GitHub Issue」行があれば更新、なければ先頭に追加
if grep -q "^\*\*GitHub Issue\*\*:" "$TASK_FILE"; then
  # 既存の行を更新
  sed -i.bak "s|^\*\*GitHub Issue\*\*:.*|\*\*GitHub Issue\*\*: [#${ISSUE_NUMBER}](${ISSUE_URL})|" "$TASK_FILE"
  rm -f "${TASK_FILE}.bak"
else
  # タイトル行の直後に追加
  sed -i.bak "/^# /a\\
\\
**GitHub Issue**: [#${ISSUE_NUMBER}](${ISSUE_URL})" "$TASK_FILE"
  rm -f "${TASK_FILE}.bak"
fi

echo "✅ タスクファイルを更新しました"
echo ""
echo "次のステップ:"
echo "  1. タスクを開始: ./scripts/move-task.sh ${TASK_ID} in-progress"
echo "  2. または手動で移動:"
echo "     mv ${TASK_FILE} .claude/tasks/in-progress/[instance-name]/"
echo "     ./scripts/update-issue-status.sh ${ISSUE_NUMBER} in-progress"
