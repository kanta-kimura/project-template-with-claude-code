#!/bin/bash

# 統合タスク管理スクリプト
#
# 使い方:
#   ./scripts/task.sh <command> [args]
#
# コマンド:
#   list [status]     - タスク一覧
#   create <title>    - タスク作成
#   start <id>        - タスク開始
#   review <id>       - レビュー依頼
#   done <id>         - タスク完了
#   status <id> <s>   - ステータス変更
#   show <id>         - タスク詳細表示

set -e

CONFIG_FILE=".claude/config.yaml"
TASKS_DIR=".claude/tasks"

# カラー
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 設定読み込み
get_mode() {
  if [ -f "$CONFIG_FILE" ]; then
    grep "mode:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '"'
  else
    echo "github"
  fi
}

MODE=$(get_mode)

# 使い方表示
usage() {
  cat <<EOF
タスク管理スクリプト (モード: $MODE)

使い方: $0 <command> [args]

コマンド:
  list [status]     タスク一覧を表示
  create <title>    新規タスクを作成
  start <id>        タスクを開始 (in-progress)
  review <id>       レビュー依頼 (review)
  done <id>         タスク完了 (completed)
  show <id>         タスク詳細を表示

ステータス: backlog, in-progress, review, completed

例:
  $0 list
  $0 list backlog
  $0 create "ユーザー認証機能"
  $0 start 123
  $0 done 123
EOF
  exit 1
}

# === GitHub モード ===

gh_list() {
  local status=${1:-""}
  echo -e "${BLUE}📋 タスク一覧 (GitHub Issues)${NC}"
  echo ""

  if [ -n "$status" ]; then
    gh issue list --label "status: $status" --limit 50
  else
    gh issue list --limit 50
  fi
}

gh_create() {
  local title=$1
  [ -z "$title" ] && echo "エラー: タイトルを指定してください" && exit 1

  echo -e "${BLUE}📝 Issue を作成中...${NC}"
  gh issue create --title "$title" --label "status: backlog"
}

gh_start() {
  local id=$1
  [ -z "$id" ] && echo "エラー: Issue番号を指定してください" && exit 1

  echo -e "${BLUE}🚀 Issue #$id を開始${NC}"
  gh issue edit "$id" --add-label "status: in-progress" --remove-label "status: backlog" 2>/dev/null || \
  gh issue edit "$id" --add-label "status: in-progress"
  gh issue comment "$id" --body "🚀 作業を開始しました"
}

gh_review() {
  local id=$1
  [ -z "$id" ] && echo "エラー: Issue番号を指定してください" && exit 1

  echo -e "${BLUE}👀 Issue #$id をレビュー依頼${NC}"
  gh issue edit "$id" --add-label "status: review" --remove-label "status: in-progress" 2>/dev/null || \
  gh issue edit "$id" --add-label "status: review"
  gh issue comment "$id" --body "👀 レビューをお願いします"
}

gh_done() {
  local id=$1
  [ -z "$id" ] && echo "エラー: Issue番号を指定してください" && exit 1

  echo -e "${BLUE}✅ Issue #$id を完了${NC}"
  gh issue close "$id" --comment "✅ 完了しました"
}

gh_show() {
  local id=$1
  [ -z "$id" ] && echo "エラー: Issue番号を指定してください" && exit 1
  gh issue view "$id"
}

# === ローカルモード ===

local_list() {
  local filter_status=${1:-""}
  echo -e "${BLUE}📋 タスク一覧 (ローカル)${NC}"
  echo ""

  printf "%-12s %-10s %-10s %s\n" "ID" "STATUS" "ASSIGNEE" "TITLE"
  printf "%-12s %-10s %-10s %s\n" "----" "------" "--------" "-----"

  for file in "$TASKS_DIR"/TASK-*.md; do
    [ -f "$file" ] || continue

    local id=$(grep "^id:" "$file" 2>/dev/null | awk '{print $2}')
    local status=$(grep "^status:" "$file" 2>/dev/null | awk '{print $2}')
    local assignee=$(grep "^assignee:" "$file" 2>/dev/null | awk '{print $2}')
    local title=$(grep "^# " "$file" 2>/dev/null | head -1 | sed 's/^# //')

    [ -z "$id" ] && id=$(basename "$file" .md)
    [ -z "$status" ] && status="backlog"
    [ -z "$assignee" ] && assignee="-"
    [ -z "$title" ] && title="(無題)"

    # フィルタ
    if [ -n "$filter_status" ] && [ "$status" != "$filter_status" ]; then
      continue
    fi

    printf "%-12s %-10s %-10s %s\n" "$id" "$status" "$assignee" "${title:0:40}"
  done
}

local_create() {
  local title=$1
  [ -z "$title" ] && echo "エラー: タイトルを指定してください" && exit 1

  # 次のID を決定
  local max_id=$(ls "$TASKS_DIR"/TASK-*.md 2>/dev/null | sed 's/.*TASK-\([0-9]*\).*/\1/' | sort -n | tail -1)
  local next_id=$((${max_id:-0} + 1))
  local task_id=$(printf "TASK-%03d" $next_id)
  local file="$TASKS_DIR/${task_id}.md"
  local today=$(date +%Y-%m-%d)

  mkdir -p "$TASKS_DIR"

  cat > "$file" <<EOF
---
id: $task_id
status: backlog
assignee:
issue:
created: $today
updated: $today
---

# $title

## 概要



## 要件

- [ ]

## 依存



## メモ

EOF

  echo -e "${GREEN}✅ タスクを作成しました: $file${NC}"
  echo "   ID: $task_id"
  echo "   Title: $title"
}

local_update_status() {
  local id=$1
  local new_status=$2
  local assignee=${3:-""}

  local file="$TASKS_DIR/${id}.md"
  [ ! -f "$file" ] && echo "エラー: $file が見つかりません" && exit 1

  local today=$(date +%Y-%m-%d)

  # status 更新
  sed -i.bak "s/^status:.*/status: $new_status/" "$file"
  sed -i.bak "s/^updated:.*/updated: $today/" "$file"

  # assignee 更新
  if [ -n "$assignee" ]; then
    sed -i.bak "s/^assignee:.*/assignee: $assignee/" "$file"
  fi

  rm -f "${file}.bak"
  echo -e "${GREEN}✅ $id のステータスを $new_status に更新${NC}"
}

local_start() {
  local id=$1
  local assignee=${2:-$(whoami)}
  local_update_status "$id" "in-progress" "$assignee"
}

local_review() {
  local id=$1
  local_update_status "$id" "review"
}

local_done() {
  local id=$1
  local_update_status "$id" "completed"
}

local_show() {
  local id=$1
  local file="$TASKS_DIR/${id}.md"
  [ ! -f "$file" ] && echo "エラー: $file が見つかりません" && exit 1
  cat "$file"
}

# === メイン ===

[ $# -lt 1 ] && usage

CMD=$1
shift

case "$MODE" in
  github)
    case "$CMD" in
      list)   gh_list "$@" ;;
      create) gh_create "$@" ;;
      start)  gh_start "$@" ;;
      review) gh_review "$@" ;;
      done)   gh_done "$@" ;;
      show)   gh_show "$@" ;;
      *)      usage ;;
    esac
    ;;
  local)
    case "$CMD" in
      list)   local_list "$@" ;;
      create) local_create "$@" ;;
      start)  local_start "$@" ;;
      review) local_review "$@" ;;
      done)   local_done "$@" ;;
      show)   local_show "$@" ;;
      *)      usage ;;
    esac
    ;;
  *)
    echo "エラー: 不明なモード '$MODE'"
    exit 1
    ;;
esac
