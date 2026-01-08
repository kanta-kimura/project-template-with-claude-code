# GitHub Issue 統合ワークフロー

GitHub Issue を活用した実装フローのガイドです。

## 概要

GitHub Issue をタスク管理の中心として、`.claude/tasks/` と連携させます。

### メリット

- **可視性**: チーム全体でタスクを共有
- **トレーサビリティ**: コミット・PR と Issue の自動連携
- **通知**: Issue の更新を通知
- **GitHub機能**: ラベル、マイルストーン、プロジェクトボードの活用

## Issue 体系

### Issue の種類

#### 1. Epic Issue（大機能）

**ラベル**: `epic`
**目的**: 大きな機能単位を管理

```markdown
# [Epic] ユーザー認証機能

## 概要
JWT トークンベースの認証システムを実装

## 関連仕様
- `docs/specs/features/user-authentication.md`

## 子Issue
- #123 データベーススキーマ設計
- #124 ユーザーモデル実装
- #125 認証API実装
- #126 認証ミドルウェア実装

## 完了条件
- [ ] すべての子Issueが完了
- [ ] E2Eテストが成功
- [ ] ドキュメント更新
```

#### 2. Feature Issue（機能）

**ラベル**: `feature`
**目的**: 実装可能な単位の機能

```markdown
# [Feature] ユーザーモデル実装

## 概要
ユーザー情報を管理するモデルを実装

## 関連
- Epic: #122
- 仕様: `docs/specs/features/user-authentication.md`
- 実装計画: `.claude/plans/user-authentication.md`

## タスク
- [ ] User モデル作成
- [ ] バリデーション実装
- [ ] 単体テスト作成

## 依存
- #123 （データベーススキーマ設計）

## 推定工数
4時間

## 担当
claude-1
```

#### 3. Bug Issue（バグ）

**ラベル**: `bug`

```markdown
# [Bug] ログイン時にセッションが保存されない

## 現象
ログイン成功後、ページをリロードするとログアウト状態になる

## 再現手順
1. ログイン画面でメール・パスワードを入力
2. ログインボタンをクリック
3. ダッシュボードに遷移
4. F5 でリロード
5. ログイン画面に戻る

## 期待される動作
リロード後もログイン状態が維持される

## 環境
- ブラウザ: Chrome 120
- OS: macOS 14

## 優先度
High
```

#### 4. Task Issue（作業）

**ラベル**: `task`
**目的**: 実装以外の作業（ドキュメント、調査など）

```markdown
# [Task] PostgreSQL パフォーマンスチューニング調査

## 目的
N+1問題の解決方法を調査

## 調査項目
- [ ] Eager Loading の実装方法
- [ ] インデックスの最適化
- [ ] クエリプランの確認方法

## 成果物
- 調査レポート: `docs/research/postgresql-tuning.md`
```

## ラベル体系

### 優先度

- `priority: critical` - 緊急対応が必要
- `priority: high` - 高優先度
- `priority: medium` - 中優先度
- `priority: low` - 低優先度

### ステータス

- `status: backlog` - 未着手
- `status: in-progress` - 実装中
- `status: review` - レビュー中
- `status: blocked` - ブロック中
- `status: completed` - 完了

### 種類

- `epic` - Epic Issue
- `feature` - 新機能
- `bug` - バグ修正
- `task` - タスク
- `refactor` - リファクタリング
- `docs` - ドキュメント
- `test` - テスト

### その他

- `good first issue` - 初心者向け
- `help wanted` - 協力募集
- `duplicate` - 重複
- `wontfix` - 修正しない

## Issue テンプレート

GitHub の Issue テンプレートを作成します。

### .github/ISSUE_TEMPLATE/feature.md

```yaml
---
name: Feature Request
about: 新機能の提案
title: '[Feature] '
labels: feature
assignees: ''
---

## 概要
[機能の概要を簡潔に記載]

## 背景・目的
[なぜこの機能が必要か]

## 関連
- Epic: #
- 仕様: `docs/specs/features/`
- 実装計画: `.claude/plans/`

## タスク
- [ ] タスク1
- [ ] タスク2
- [ ] タスク3

## 依存
- #（依存するIssue番号）

## 推定工数
[時間/日]

## 完了条件
- [ ] 実装完了
- [ ] テスト作成
- [ ] ドキュメント更新
```

### .github/ISSUE_TEMPLATE/bug.md

```yaml
---
name: Bug Report
about: バグの報告
title: '[Bug] '
labels: bug
assignees: ''
---

## 現象
[何が起きているか]

## 再現手順
1.
2.
3.

## 期待される動作
[どうあるべきか]

## 実際の動作
[実際に何が起きたか]

## 環境
- OS:
- ブラウザ:
- バージョン:

## スクリーンショット
[該当する場合]

## 優先度
- [ ] Critical
- [ ] High
- [ ] Medium
- [ ] Low
```

## ワークフロー

### 1. Issue 作成フロー

#### ステップ1: Epic Issue 作成

大きな機能を実装する場合、まず Epic Issue を作成します。

```bash
# GitHub CLI を使用
gh issue create \
  --title "[Epic] ユーザー認証機能" \
  --label "epic" \
  --body-file .claude/plans/user-authentication.md
```

#### ステップ2: 実装計画からタスク Issue を作成

実装計画書（`.claude/plans/`）に基づいて、複数のタスク Issue を作成します。

```bash
# 例: 実装計画から自動生成（スクリプト例）
# scripts/create-issues-from-plan.sh

#!/bin/bash

PLAN_FILE=".claude/plans/user-authentication.md"
EPIC_NUMBER=122

# TASK-001: データベーススキーマ設計
gh issue create \
  --title "[Feature] データベーススキーマ設計" \
  --label "feature,status: backlog" \
  --body "Epic: #${EPIC_NUMBER}

実装内容:
- users テーブル設計
- sessions テーブル設計
- マイグレーションファイル作成

推定工数: 2時間"

# TASK-002: ユーザーモデル実装
gh issue create \
  --title "[Feature] ユーザーモデル実装" \
  --label "feature,status: backlog" \
  --body "Epic: #${EPIC_NUMBER}

依存: #123

実装内容:
- User モデル作成
- バリデーション実装
- 単体テスト作成

推定工数: 4時間"
```

### 2. Issue → タスクファイル生成

Claude Code が Issue を取得し、タスクファイルを生成します。

#### 自動スクリプト例

```bash
# scripts/sync-issue-to-task.sh

#!/bin/bash

ISSUE_NUMBER=$1

# Issue情報を取得
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body,labels)

ISSUE_TITLE=$(echo $ISSUE_JSON | jq -r '.title')
ISSUE_BODY=$(echo $ISSUE_JSON | jq -r '.body')

# タスクファイルを生成
TASK_FILE=".claude/tasks/backlog/TASK-${ISSUE_NUMBER}.md"

cat > $TASK_FILE <<EOF
# TASK-${ISSUE_NUMBER}: ${ISSUE_TITLE}

**GitHub Issue**: #${ISSUE_NUMBER}

## 概要

${ISSUE_BODY}

## ステータス

GitHub Issue と同期しています。
- Issue URL: https://github.com/owner/repo/issues/${ISSUE_NUMBER}

## 実装履歴

| 日付 | 担当インスタンス | ステータス | メモ |
|------|----------------|-----------|------|
| $(date +%Y-%m-%d) | - | backlog | Issue から生成 |
EOF

echo "✅ タスクファイルを生成しました: $TASK_FILE"
echo "📝 Issue #${ISSUE_NUMBER} と同期"
```

使用例:

```bash
# Issue #123 からタスクファイル生成
./scripts/sync-issue-to-task.sh 123
```

### 3. Claude Code の作業フロー

#### ステップ1: Issue からタスクを取得

```bash
# 未着手の Issue 一覧を取得
gh issue list --label "status: backlog" --limit 10

# 特定の Issue をタスクファイルに変換
./scripts/sync-issue-to-task.sh 123
```

Claude Code インスタンスが実行:

```bash
# 1. Issue情報を取得
gh issue view 123

# 2. タスクファイルを生成
./scripts/sync-issue-to-task.sh 123

# 3. タスクを in-progress に移動
mv .claude/tasks/backlog/TASK-123.md .claude/tasks/in-progress/claude-1/

# 4. Issue のステータスを更新
gh issue edit 123 --add-label "status: in-progress" --remove-label "status: backlog"
```

#### ステップ2: 実装

通常の実装フローに従って実装します。

#### ステップ3: コミット時に Issue を参照

```bash
git commit -m "[feat] ユーザーモデルを実装

Refs #123"
```

#### ステップ4: レビュー

```bash
# タスクを review に移動
mv .claude/tasks/in-progress/claude-1/TASK-123.md .claude/tasks/review/

# Issue のステータスを更新
gh issue edit 123 --add-label "status: review" --remove-label "status: in-progress"
```

#### ステップ5: 完了

```bash
# タスクを completed に移動
mv .claude/tasks/review/TASK-123.md .claude/tasks/completed/

# Issue をクローズ
gh issue close 123 --comment "実装完了。レビューも承認されました。"
```

### 4. プルリクエストとの連携

PR 作成時に Issue を自動的にリンクします。

```bash
# PR作成（Issue を自動クローズ）
gh pr create \
  --title "ユーザーモデルを実装" \
  --body "Closes #123

## 変更内容
- User モデル作成
- バリデーション実装
- 単体テスト作成

## テスト
- [x] 単体テスト成功
- [x] カバレッジ 85%"
```

## GitHub Projects との連携

GitHub Projects (Beta) を使用してカンバンボードで管理します。

### プロジェクトボードの設定

1. **Columns**:
   - Backlog
   - In Progress
   - Review
   - Done

2. **自動化**:
   - Issue にラベル `status: in-progress` が付いたら In Progress に移動
   - Issue にラベル `status: review` が付いたら Review に移動
   - Issue がクローズされたら Done に移動

### GitHub Actions での自動化

```yaml
# .github/workflows/issue-automation.yml
name: Issue Automation

on:
  issues:
    types: [opened, labeled, unlabeled, closed]

jobs:
  sync-project:
    runs-on: ubuntu-latest
    steps:
      - name: Move to In Progress
        if: contains(github.event.issue.labels.*.name, 'status: in-progress')
        uses: actions/add-to-project@v0.4.0
        with:
          project-url: https://github.com/orgs/ORG/projects/1
          github-token: ${{ secrets.PROJECT_TOKEN }}

      - name: Update dashboard
        if: github.event.action == 'labeled' || github.event.action == 'closed'
        run: |
          # .claude/dashboard.md を更新するスクリプト
          ./scripts/update-dashboard.sh
```

## ベストプラクティス

### 1. Issue の粒度

- **Epic**: 1〜2週間の作業量
- **Feature**: 1〜2日の作業量
- **Task**: 数時間の作業量

### 2. ラベルの一貫性

すべての Issue に以下を付与:
- 種類（feature, bug, task など）
- ステータス（backlog, in-progress など）
- 優先度（priority: high など）

### 3. Issue のクローズ条件

Issue をクローズする前に:
- [ ] 実装完了
- [ ] テスト成功
- [ ] レビュー承認
- [ ] ドキュメント更新

### 4. コミットメッセージ

必ず Issue を参照:
```
[feat] ユーザーモデルを実装

Refs #123
```

または自動クローズ:
```
[feat] バグを修正

Fixes #456
```

## スクリプト集

プロジェクトに以下のスクリプトを追加することを推奨します:

### scripts/create-issues-from-plan.sh

実装計画書から Issue を一括作成

### scripts/sync-issue-to-task.sh

Issue からタスクファイルを生成

### scripts/update-issue-status.sh

タスクの移動時に Issue のステータスを更新

### scripts/update-dashboard.sh

Issue の状態から `.claude/dashboard.md` を更新

## トラブルシューティング

### Issue とタスクファイルが同期しない

原因: 手動でタスクファイルを移動した際に Issue を更新し忘れ

対策:
```bash
# タスク移動時は必ずスクリプトを使用
./scripts/move-task.sh TASK-123 review
```

### 重複した Issue が作成される

原因: 既存 Issue を確認せずに作成

対策:
```bash
# 作成前に検索
gh issue list --search "ユーザーモデル"
```

## 参考資料

- [GitHub Issues ドキュメント](https://docs.github.com/ja/issues)
- [GitHub CLI ドキュメント](https://cli.github.com/manual/)
- [GitHub Projects ドキュメント](https://docs.github.com/ja/issues/planning-and-tracking-with-projects)
