#!/bin/bash

# ダッシュボードを自動更新するスクリプト
#
# 使い方:
#   ./scripts/update-dashboard.sh
#
# 機能:
#   - .claude/tasks/ ディレクトリをスキャンしてタスク状況を集計
#   - .claude/dashboard.md を自動更新
#   - 競合を避けるためロックファイルを使用

set -e

DASHBOARD_FILE=".claude/dashboard.md"
LOCK_FILE=".claude/.dashboard.lock"
TASKS_DIR=".claude/tasks"

# ロック取得（競合回避）
acquire_lock() {
  local timeout=30
  local count=0

  while [ -f "$LOCK_FILE" ]; do
    if [ $count -ge $timeout ]; then
      echo "エラー: ロック取得タイムアウト（別のプロセスが更新中の可能性）"
      echo "手動で解除: rm $LOCK_FILE"
      exit 1
    fi
    echo "⏳ 他のプロセスが更新中です。待機中... ($count/$timeout)"
    sleep 1
    count=$((count + 1))
  done

  # ロック取得
  echo $$ > "$LOCK_FILE"
  trap "rm -f '$LOCK_FILE'" EXIT
}

# タスクファイルから情報を抽出
extract_task_info() {
  local file=$1
  local task_id=$(basename "$file" .md)
  local title=$(grep -m 1 "^# " "$file" 2>/dev/null | sed 's/^# //' | sed "s/${task_id}: //" || echo "$task_id")
  local issue=$(grep -oP '(?<=GitHub Issue.*#)\d+' "$file" 2>/dev/null | head -1 || echo "-")
  echo "${task_id}|${title}|${issue}"
}

# タスクを集計
count_tasks() {
  local backlog=0
  local in_progress=0
  local review=0
  local completed=0

  # backlog
  if [ -d "${TASKS_DIR}/backlog" ]; then
    backlog=$(find "${TASKS_DIR}/backlog" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  # in-progress（サブディレクトリも含む）
  if [ -d "${TASKS_DIR}/in-progress" ]; then
    in_progress=$(find "${TASKS_DIR}/in-progress" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  # review
  if [ -d "${TASKS_DIR}/review" ]; then
    review=$(find "${TASKS_DIR}/review" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  # completed
  if [ -d "${TASKS_DIR}/completed" ]; then
    completed=$(find "${TASKS_DIR}/completed" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  echo "${backlog}|${in_progress}|${review}|${completed}"
}

# ダッシュボード生成
generate_dashboard() {
  local counts=$(count_tasks)
  local backlog=$(echo "$counts" | cut -d'|' -f1)
  local in_progress=$(echo "$counts" | cut -d'|' -f2)
  local review=$(echo "$counts" | cut -d'|' -f3)
  local completed=$(echo "$counts" | cut -d'|' -f4)
  local total=$((backlog + in_progress + review + completed))

  # 割合計算
  local completed_pct=0
  local review_pct=0
  local in_progress_pct=0
  local backlog_pct=0

  if [ $total -gt 0 ]; then
    completed_pct=$((completed * 100 / total))
    review_pct=$((review * 100 / total))
    in_progress_pct=$((in_progress * 100 / total))
    backlog_pct=$((backlog * 100 / total))
  fi

  # 進捗バー生成
  local progress_bar=""
  local filled=$((completed_pct / 10))
  for i in $(seq 1 10); do
    if [ $i -le $filled ]; then
      progress_bar="${progress_bar}█"
    else
      progress_bar="${progress_bar}░"
    fi
  done

  # ダッシュボード出力
  cat <<EOF
# プロジェクト進捗ダッシュボード

最終更新: $(date '+%Y-%m-%d %H:%M:%S')

## 📊 全体サマリー

| ステータス | 件数 | 割合 |
|-----------|------|------|
| 完了 | ${completed} | ${completed_pct}% |
| レビュー中 | ${review} | ${review_pct}% |
| 実装中 | ${in_progress} | ${in_progress_pct}% |
| 未着手 | ${backlog} | ${backlog_pct}% |
| **合計** | **${total}** | **100%** |

## 🚀 実装中タスク

EOF

  # 実装中タスク一覧
  if [ -d "${TASKS_DIR}/in-progress" ]; then
    local has_tasks=false
    echo "| タスクID | タイトル | 担当インスタンス | 開始日時 | Issue |"
    echo "|---------|---------|----------------|----------|-------|"

    for instance_dir in ${TASKS_DIR}/in-progress/*/; do
      if [ -d "$instance_dir" ]; then
        local instance_name=$(basename "$instance_dir")
        for file in "${instance_dir}"*.md; do
          if [ -f "$file" ]; then
            has_tasks=true
            local info=$(extract_task_info "$file")
            local task_id=$(echo "$info" | cut -d'|' -f1)
            local title=$(echo "$info" | cut -d'|' -f2 | cut -c1-30)
            local issue=$(echo "$info" | cut -d'|' -f3)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            echo "| ${task_id} | ${title} | ${instance_name} | ${date} | #${issue} |"
          fi
        done
      fi
    done

    if [ "$has_tasks" = false ]; then
      echo ""
      echo "現在実装中のタスクはありません。"
    fi
  else
    echo "現在実装中のタスクはありません。"
  fi

  cat <<EOF

## 👀 レビュー待ちタスク

EOF

  # レビュー待ちタスク一覧
  if [ -d "${TASKS_DIR}/review" ] && [ "$(ls -A ${TASKS_DIR}/review/*.md 2>/dev/null)" ]; then
    echo "| タスクID | タイトル | 実装完了日時 | レビュアー | Issue |"
    echo "|---------|---------|-------------|-----------|-------|"

    for file in ${TASKS_DIR}/review/*.md; do
      if [ -f "$file" ]; then
        local info=$(extract_task_info "$file")
        local task_id=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2 | cut -c1-30)
        local issue=$(echo "$info" | cut -d'|' -f3)
        local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        echo "| ${task_id} | ${title} | ${date} | - | #${issue} |"
      fi
    done
  else
    echo "レビュー待ちのタスクはありません。"
  fi

  cat <<EOF

## 📋 Backlog

EOF

  # Backlog 一覧
  if [ -d "${TASKS_DIR}/backlog" ] && [ "$(ls -A ${TASKS_DIR}/backlog/*.md 2>/dev/null)" ]; then
    echo "| タスクID | タイトル | 優先度 | 依存タスク | Issue |"
    echo "|---------|---------|-------|-----------|-------|"

    for file in ${TASKS_DIR}/backlog/*.md; do
      if [ -f "$file" ]; then
        local info=$(extract_task_info "$file")
        local task_id=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2 | cut -c1-30)
        local issue=$(echo "$info" | cut -d'|' -f3)
        echo "| ${task_id} | ${title} | - | - | #${issue} |"
      fi
    done
  else
    echo "未着手のタスクはありません。"
  fi

  cat <<EOF

## ✅ 完了タスク（直近10件）

EOF

  # 完了タスク一覧（直近10件）
  if [ -d "${TASKS_DIR}/completed" ] && [ "$(ls -A ${TASKS_DIR}/completed/*.md 2>/dev/null)" ]; then
    echo "| タスクID | タイトル | 完了日時 | 担当インスタンス | Issue |"
    echo "|---------|---------|---------|----------------|-------|"

    # 更新日時でソートして直近10件
    ls -t ${TASKS_DIR}/completed/*.md 2>/dev/null | head -10 | while read file; do
      if [ -f "$file" ]; then
        local info=$(extract_task_info "$file")
        local task_id=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2 | cut -c1-30)
        local issue=$(echo "$info" | cut -d'|' -f3)
        local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        echo "| ${task_id} | ${title} | ${date} | - | #${issue} |"
      fi
    done
  else
    echo "完了したタスクはありません。"
  fi

  cat <<EOF

## 📈 進捗グラフ

\`\`\`
進捗: [${progress_bar}] ${completed_pct}%
\`\`\`

---

## 使い方

このファイルは \`./scripts/update-dashboard.sh\` で自動更新されます。

### 手動更新
\`\`\`bash
./scripts/update-dashboard.sh
\`\`\`

### タスク移動時の自動更新
\`\`\`bash
# タスク移動スクリプトを使用すると自動的にダッシュボードも更新されます
./scripts/move-task.sh TASK-XXX in-progress
./scripts/move-task.sh TASK-XXX review
./scripts/move-task.sh TASK-XXX completed
\`\`\`

### gh CLI コマンド

\`\`\`bash
# Issue ステータスを in-progress に変更
gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"

# Issue ステータスを review に変更
gh issue edit <number> --add-label "status: review" --remove-label "status: in-progress"

# Issue をクローズ
gh issue close <number> --comment "実装完了。レビュー承認されました。"
\`\`\`
EOF
}

# メイン処理
echo "🔄 ダッシュボードを更新中..."

# ロック取得
acquire_lock

# ダッシュボード生成
generate_dashboard > "$DASHBOARD_FILE"

echo "✅ ダッシュボードを更新しました: ${DASHBOARD_FILE}"
