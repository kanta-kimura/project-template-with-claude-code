#!/bin/bash

# GitHub Issue からタスクファイルを生成するスクリプト
#
# 使い方:
#   ./scripts/sync-issue-to-task.sh <issue-number>
#
# 例:
#   ./scripts/sync-issue-to-task.sh 123

set -e

# 引数チェック
if [ -z "$1" ]; then
  echo "エラー: Issue番号を指定してください"
  echo "使い方: $0 <issue-number>"
  exit 1
fi

ISSUE_NUMBER=$1

# GitHub CLI がインストールされているか確認
if ! command -v gh &> /dev/null; then
  echo "エラー: GitHub CLI (gh) がインストールされていません"
  echo "インストール方法: https://cli.github.com/"
  exit 1
fi

# Issue 情報を取得
echo "📥 Issue #${ISSUE_NUMBER} の情報を取得中..."

ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body,labels,assignees,milestone 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "エラー: Issue #${ISSUE_NUMBER} が見つかりません"
  exit 1
fi

# JSON から情報を抽出
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body // ""')
ISSUE_LABELS=$(echo "$ISSUE_JSON" | jq -r '.labels[].name' | tr '\n' ', ' | sed 's/,$//')
ASSIGNEES=$(echo "$ISSUE_JSON" | jq -r '.assignees[].login' | tr '\n' ', ' | sed 's/,$//')

# タスクファイルのパスを決定
TASK_DIR=".claude/tasks/backlog"
TASK_FILE="${TASK_DIR}/TASK-${ISSUE_NUMBER}.md"

# ディレクトリが存在しない場合は作成
mkdir -p "$TASK_DIR"

# タスクファイルを生成
echo "📝 タスクファイルを生成中: ${TASK_FILE}"

cat > "$TASK_FILE" <<EOF
# TASK-${ISSUE_NUMBER}: ${ISSUE_TITLE}

**GitHub Issue**: [#${ISSUE_NUMBER}](https://github.com/\$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/${ISSUE_NUMBER})

**ラベル**: ${ISSUE_LABELS}
**担当**: ${ASSIGNEES:-未割り当て}

## 概要

${ISSUE_BODY}

---

## 実装ガイド

### ステップ

1. **Issue の詳細を確認**
   \`\`\`bash
   gh issue view ${ISSUE_NUMBER}
   \`\`\`

2. **ブランチを作成**
   \`\`\`bash
   git checkout -b feature/issue-${ISSUE_NUMBER}
   \`\`\`

3. **実装**
   - コーディング規約に従って実装
   - 参考: \`docs/rules/coding-standards/\`

4. **テスト**
   - 単体テストを作成
   - カバレッジ 80% 以上を目標

5. **コミット**
   \`\`\`bash
   git commit -m "[feat] ${ISSUE_TITLE}

   Refs #${ISSUE_NUMBER}"
   \`\`\`

6. **プッシュ & PR作成**
   \`\`\`bash
   git push origin feature/issue-${ISSUE_NUMBER}
   gh pr create --title "${ISSUE_TITLE}" --body "Closes #${ISSUE_NUMBER}"
   \`\`\`

### コーディング規約

参考: \`docs/rules/coding-standards/\`

### セキュリティチェック

参考: \`docs/rules/security.md\`

- [ ] 入力バリデーション
- [ ] SQLインジェクション対策
- [ ] XSS対策
- [ ] 機密情報の保護

## 完了条件

Issue に記載された完了条件を確認してください。

- [ ] 実装完了
- [ ] 単体テスト作成・成功
- [ ] コーディング規約準拠
- [ ] セキュリティチェック完了
- [ ] ドキュメント更新
- [ ] コミット完了

## GitHub Issue との同期

このタスクファイルは GitHub Issue #${ISSUE_NUMBER} と連動しています。

### ステータス更新

タスクを \`in-progress\` に移動する際:
\`\`\`bash
./scripts/update-issue-status.sh ${ISSUE_NUMBER} in-progress
\`\`\`

タスクを \`review\` に移動する際:
\`\`\`bash
./scripts/update-issue-status.sh ${ISSUE_NUMBER} review
\`\`\`

タスクを \`completed\` に移動する際:
\`\`\`bash
./scripts/update-issue-status.sh ${ISSUE_NUMBER} completed
gh issue close ${ISSUE_NUMBER} --comment "実装完了。レビューも承認されました。"
\`\`\`

---

## 実装履歴

| 日付 | 担当インスタンス | ステータス | メモ |
|------|----------------|-----------|------|
| $(date +%Y-%m-%d) | - | backlog | Issue #${ISSUE_NUMBER} から生成 |
EOF

echo ""
echo "✅ タスクファイルを生成しました!"
echo "📄 ファイル: ${TASK_FILE}"
echo "🔗 Issue: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/${ISSUE_NUMBER}"
echo ""
echo "次のステップ:"
echo "  1. タスクファイルを確認: cat ${TASK_FILE}"
echo "  2. タスクを開始: mv ${TASK_FILE} .claude/tasks/in-progress/[instance-name]/"
echo "  3. Issue のステータスを更新: ./scripts/update-issue-status.sh ${ISSUE_NUMBER} in-progress"
