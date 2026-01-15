#!/bin/bash

# タスク移動スクリプト（一括処理）
#
# 使い方:
#   ./scripts/move-task.sh <task-id> <target-status> [instance-name]
#
# 例:
#   ./scripts/move-task.sh TASK-001 in-progress claude-1
#   ./scripts/move-task.sh TASK-001 review
#   ./scripts/move-task.sh TASK-001 completed
#
# 処理内容:
#   1. タスクファイルを移動
#   2. GitHub Issue のステータスを更新
#   3. ダッシュボードを更新

set -e

TASKS_DIR=".claude/tasks"
SCRIPTS_DIR="scripts"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 使い方表示
usage() {
  echo "使い方: $0 <task-id> <target-status> [instance-name]"
  echo ""
  echo "target-status:"
  echo "  in-progress  - タスクを開始（instance-name 必須）"
  echo "  review       - レビュー依頼"
  echo "  completed    - タスク完了"
  echo "  backlog      - バックログに戻す"
  echo ""
  echo "例:"
  echo "  $0 TASK-001 in-progress claude-1"
  echo "  $0 TASK-001 review"
  echo "  $0 TASK-001 completed"
  exit 1
}

# 引数チェック
if [ -z "$1" ] || [ -z "$2" ]; then
  usage
fi

TASK_ID=$1
TARGET_STATUS=$2
INSTANCE_NAME=${3:-"default"}

# ステータス検証
case "$TARGET_STATUS" in
  backlog|in-progress|review|completed)
    ;;
  *)
    echo -e "${RED}エラー: 無効なステータス '${TARGET_STATUS}'${NC}"
    usage
    ;;
esac

# in-progress の場合は instance-name 必須
if [ "$TARGET_STATUS" = "in-progress" ] && [ "$INSTANCE_NAME" = "default" ]; then
  echo -e "${RED}エラー: in-progress の場合は instance-name を指定してください${NC}"
  echo "例: $0 ${TASK_ID} in-progress claude-1"
  exit 1
fi

# タスクファイルを検索
find_task_file() {
  local task_id=$1
  local found=""

  # 各ディレクトリを検索
  for status_dir in backlog in-progress review completed; do
    local dir="${TASKS_DIR}/${status_dir}"

    if [ -d "$dir" ]; then
      # 直接ファイルを検索
      if [ -f "${dir}/${task_id}.md" ]; then
        echo "${dir}/${task_id}.md|${status_dir}|"
        return
      fi

      # サブディレクトリを検索（in-progress/[instance-name]/）
      for subdir in ${dir}/*/; do
        if [ -d "$subdir" ] && [ -f "${subdir}${task_id}.md" ]; then
          local instance=$(basename "$subdir")
          echo "${subdir}${task_id}.md|${status_dir}|${instance}"
          return
        fi
      done
    fi
  done

  echo ""
}

# Issue 番号を抽出
extract_issue_number() {
  local file=$1
  grep -oP '(?<=GitHub Issue.*#)\d+' "$file" 2>/dev/null | head -1 || echo ""
}

echo "🔍 タスクファイルを検索中: ${TASK_ID}"

# タスクファイルを検索
TASK_INFO=$(find_task_file "$TASK_ID")

if [ -z "$TASK_INFO" ]; then
  echo -e "${RED}エラー: タスクファイル '${TASK_ID}.md' が見つかりません${NC}"
  exit 1
fi

TASK_FILE=$(echo "$TASK_INFO" | cut -d'|' -f1)
CURRENT_STATUS=$(echo "$TASK_INFO" | cut -d'|' -f2)
CURRENT_INSTANCE=$(echo "$TASK_INFO" | cut -d'|' -f3)

echo "📄 タスクファイル: ${TASK_FILE}"
echo "📌 現在のステータス: ${CURRENT_STATUS}"

# 同じステータスへの移動はスキップ
if [ "$CURRENT_STATUS" = "$TARGET_STATUS" ]; then
  echo -e "${YELLOW}⚠️  既に '${TARGET_STATUS}' ステータスです${NC}"
  exit 0
fi

# 移動先ディレクトリを決定
case "$TARGET_STATUS" in
  backlog)
    TARGET_DIR="${TASKS_DIR}/backlog"
    ;;
  in-progress)
    TARGET_DIR="${TASKS_DIR}/in-progress/${INSTANCE_NAME}"
    mkdir -p "$TARGET_DIR"
    ;;
  review)
    TARGET_DIR="${TASKS_DIR}/review"
    ;;
  completed)
    TARGET_DIR="${TASKS_DIR}/completed"
    ;;
esac

TARGET_FILE="${TARGET_DIR}/${TASK_ID}.md"

echo "📁 移動先: ${TARGET_FILE}"

# Issue 番号を取得
ISSUE_NUMBER=$(extract_issue_number "$TASK_FILE")

# Step 1: タスクファイルを移動
echo ""
echo "1️⃣  タスクファイルを移動中..."
mv "$TASK_FILE" "$TARGET_FILE"
echo -e "${GREEN}   ✅ 移動完了${NC}"

# Step 2: GitHub Issue のステータスを更新
echo ""
echo "2️⃣  GitHub Issue を更新中..."

if [ -n "$ISSUE_NUMBER" ]; then
  # ステータスラベルを更新
  case "$TARGET_STATUS" in
    backlog)
      gh issue edit "$ISSUE_NUMBER" --add-label "status: backlog" --remove-label "status: in-progress" --remove-label "status: review" 2>/dev/null || true
      echo -e "${GREEN}   ✅ Issue #${ISSUE_NUMBER} を backlog に更新${NC}"
      ;;
    in-progress)
      gh issue edit "$ISSUE_NUMBER" --add-label "status: in-progress" --remove-label "status: backlog" --remove-label "status: review" 2>/dev/null || true
      gh issue comment "$ISSUE_NUMBER" --body "🚀 実装を開始しました (${INSTANCE_NAME})" 2>/dev/null || true
      echo -e "${GREEN}   ✅ Issue #${ISSUE_NUMBER} を in-progress に更新${NC}"
      ;;
    review)
      gh issue edit "$ISSUE_NUMBER" --add-label "status: review" --remove-label "status: in-progress" 2>/dev/null || true
      gh issue comment "$ISSUE_NUMBER" --body "👀 レビュー待ちです" 2>/dev/null || true
      echo -e "${GREEN}   ✅ Issue #${ISSUE_NUMBER} を review に更新${NC}"
      ;;
    completed)
      gh issue close "$ISSUE_NUMBER" --comment "✅ 実装完了。レビュー承認されました。" 2>/dev/null || true
      echo -e "${GREEN}   ✅ Issue #${ISSUE_NUMBER} をクローズ${NC}"
      ;;
  esac
else
  echo -e "${YELLOW}   ⚠️  Issue 番号が見つかりません（スキップ）${NC}"
fi

# Step 3: タスクファイルの実装履歴を更新
echo ""
echo "3️⃣  タスクファイルの履歴を更新中..."

DATE=$(date '+%Y-%m-%d')
HISTORY_LINE="| ${DATE} | ${INSTANCE_NAME} | ${TARGET_STATUS} | 自動移動 |"

# 実装履歴テーブルに行を追加
if grep -q "^## 実装履歴" "$TARGET_FILE" 2>/dev/null; then
  # テーブルの最後に追加
  sed -i.bak "/^## 実装履歴/,/^$/{
    /^|.*|$/a\\
${HISTORY_LINE}
  }" "$TARGET_FILE" 2>/dev/null || true
  rm -f "${TARGET_FILE}.bak"
  echo -e "${GREEN}   ✅ 履歴を追加${NC}"
else
  echo -e "${YELLOW}   ⚠️  実装履歴セクションがありません（スキップ）${NC}"
fi

# Step 4: ダッシュボードを更新
echo ""
echo "4️⃣  ダッシュボードを更新中..."

if [ -f "${SCRIPTS_DIR}/update-dashboard.sh" ]; then
  bash "${SCRIPTS_DIR}/update-dashboard.sh"
  echo -e "${GREEN}   ✅ ダッシュボード更新完了${NC}"
else
  echo -e "${YELLOW}   ⚠️  update-dashboard.sh が見つかりません${NC}"
fi

# 完了メッセージ
echo ""
echo "========================================"
echo -e "${GREEN}✅ タスク移動が完了しました${NC}"
echo "========================================"
echo ""
echo "タスク: ${TASK_ID}"
echo "移動: ${CURRENT_STATUS} → ${TARGET_STATUS}"
if [ -n "$ISSUE_NUMBER" ]; then
  echo "Issue: #${ISSUE_NUMBER}"
fi
echo ""

# 次のステップを提案
case "$TARGET_STATUS" in
  in-progress)
    echo "次のステップ:"
    echo "  1. 実装を開始"
    echo "  2. コミット時に Issue を参照: git commit -m \"[feat] 機能実装 Refs #${ISSUE_NUMBER}\""
    echo "  3. 完了後: ./scripts/move-task.sh ${TASK_ID} review"
    ;;
  review)
    echo "次のステップ:"
    echo "  1. レビューを実施"
    echo "  2. 承認後: ./scripts/move-task.sh ${TASK_ID} completed"
    echo "  3. 要修正の場合: ./scripts/move-task.sh ${TASK_ID} in-progress ${CURRENT_INSTANCE:-claude-1}"
    ;;
  completed)
    echo "🎉 タスクが完了しました！"
    ;;
esac
