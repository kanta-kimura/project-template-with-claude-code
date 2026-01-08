#!/bin/bash

# GitHub Issue のステータスラベルを更新するスクリプト
#
# 使い方:
#   ./scripts/update-issue-status.sh <issue-number> <new-status>
#
# 例:
#   ./scripts/update-issue-status.sh 123 in-progress
#   ./scripts/update-issue-status.sh 123 review
#   ./scripts/update-issue-status.sh 123 completed

set -e

# 引数チェック
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "エラー: 引数が不足しています"
  echo "使い方: $0 <issue-number> <new-status>"
  echo ""
  echo "利用可能なステータス:"
  echo "  - backlog"
  echo "  - in-progress"
  echo "  - review"
  echo "  - blocked"
  echo "  - completed"
  exit 1
fi

ISSUE_NUMBER=$1
NEW_STATUS=$2

# ステータスの検証
case "$NEW_STATUS" in
  backlog|in-progress|review|blocked|completed)
    ;;
  *)
    echo "エラー: 無効なステータス '${NEW_STATUS}'"
    echo "利用可能なステータス: backlog, in-progress, review, blocked, completed"
    exit 1
    ;;
esac

# GitHub CLI の確認
if ! command -v gh &> /dev/null; then
  echo "エラー: GitHub CLI (gh) がインストールされていません"
  exit 1
fi

echo "🔄 Issue #${ISSUE_NUMBER} のステータスを '${NEW_STATUS}' に更新中..."

# 現在のステータスラベルを削除
CURRENT_STATUS=$(gh issue view $ISSUE_NUMBER --json labels --jq '.labels[] | select(.name | startswith("status:")) | .name' 2>/dev/null || echo "")

if [ -n "$CURRENT_STATUS" ]; then
  echo "📌 現在のステータス: ${CURRENT_STATUS}"
  gh issue edit $ISSUE_NUMBER --remove-label "$CURRENT_STATUS" 2>/dev/null || true
fi

# 新しいステータスラベルを追加
NEW_LABEL="status: ${NEW_STATUS}"
echo "📌 新しいステータス: ${NEW_LABEL}"
gh issue edit $ISSUE_NUMBER --add-label "$NEW_LABEL"

# コメントを追加（オプション）
case "$NEW_STATUS" in
  in-progress)
    gh issue comment $ISSUE_NUMBER --body "🚀 実装を開始しました" 2>/dev/null || true
    ;;
  review)
    gh issue comment $ISSUE_NUMBER --body "👀 レビュー待ちです" 2>/dev/null || true
    ;;
  completed)
    gh issue comment $ISSUE_NUMBER --body "✅ 実装が完了しました" 2>/dev/null || true
    ;;
  blocked)
    gh issue comment $ISSUE_NUMBER --body "🚧 ブロック中です" 2>/dev/null || true
    ;;
esac

echo ""
echo "✅ Issue #${ISSUE_NUMBER} のステータスを更新しました"
echo "🔗 確認: gh issue view ${ISSUE_NUMBER}"
