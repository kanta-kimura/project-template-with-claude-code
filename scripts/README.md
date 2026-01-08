# スクリプト集

プロジェクト管理を効率化するためのスクリプト集です。

## GitHub Issue 連携スクリプト

### sync-issue-to-task.sh

GitHub Issue からタスクファイルを生成します。

**使い方:**
```bash
./scripts/sync-issue-to-task.sh <issue-number>
```

**例:**
```bash
# Issue #123 からタスクファイルを生成
./scripts/sync-issue-to-task.sh 123

# 生成されるファイル
# .claude/tasks/backlog/TASK-123.md
```

**処理内容:**
1. GitHub Issue の情報を取得（gh CLI を使用）
2. `.claude/tasks/backlog/TASK-{number}.md` を生成
3. Issue の内容をタスクファイルに変換

### update-issue-status.sh

GitHub Issue のステータスラベルを更新します。

**使い方:**
```bash
./scripts/update-issue-status.sh <issue-number> <new-status>
```

**利用可能なステータス:**
- `backlog` - 未着手
- `in-progress` - 実装中
- `review` - レビュー中
- `blocked` - ブロック中
- `completed` - 完了

**例:**
```bash
# Issue #123 を in-progress に変更
./scripts/update-issue-status.sh 123 in-progress

# Issue #123 を review に変更
./scripts/update-issue-status.sh 123 review

# Issue #123 を completed に変更
./scripts/update-issue-status.sh 123 completed
```

**処理内容:**
1. 現在の `status:` ラベルを削除
2. 新しい `status:` ラベルを追加
3. ステータス変更をコメントで通知

## 使用例：完全なワークフロー

### 1. Issue を取得してタスク化

```bash
# 未着手の Issue 一覧を表示
gh issue list --label "status: backlog"

# Issue #123 をタスクファイルに変換
./scripts/sync-issue-to-task.sh 123
```

### 2. タスクを開始

```bash
# タスクファイルを in-progress に移動
mv .claude/tasks/backlog/TASK-123.md .claude/tasks/in-progress/claude-1/

# Issue のステータスを更新
./scripts/update-issue-status.sh 123 in-progress
```

### 3. 実装

通常の実装フローに従って実装します。

### 4. レビュー依頼

```bash
# タスクファイルを review に移動
mv .claude/tasks/in-progress/claude-1/TASK-123.md .claude/tasks/review/

# Issue のステータスを更新
./scripts/update-issue-status.sh 123 review

# PR を作成（Issue を自動クローズ）
gh pr create --title "ユーザーモデルを実装" --body "Closes #123"
```

### 5. 完了

```bash
# レビュー承認後、タスクファイルを completed に移動
mv .claude/tasks/review/TASK-123.md .claude/tasks/completed/

# Issue をクローズ
gh issue close 123 --comment "実装完了。レビュー承認されました。"
```

## 前提条件

### GitHub CLI のインストール

これらのスクリプトは GitHub CLI (`gh`) を使用します。

**インストール方法:**

```bash
# macOS
brew install gh

# Linux
sudo apt install gh

# Windows
winget install GitHub.cli
```

**認証:**
```bash
gh auth login
```

### スクリプトの実行権限

スクリプトに実行権限を付与します。

```bash
chmod +x scripts/*.sh
```

## カスタマイズ

### Issue テンプレートのカスタマイズ

`.github/ISSUE_TEMPLATE/` のテンプレートをプロジェクトに合わせて編集してください。

### ラベルのカスタマイズ

プロジェクトで使用するラベルをカスタマイズできます。

```bash
# ラベル一覧を表示
gh label list

# 新しいラベルを作成
gh label create "priority: critical" --color "d73a4a" --description "緊急対応が必要"
```

推奨されるラベル:
- `epic` - Epic Issue
- `feature` - 新機能
- `bug` - バグ修正
- `task` - タスク
- `status: backlog` - 未着手
- `status: in-progress` - 実装中
- `status: review` - レビュー中
- `status: completed` - 完了
- `priority: critical` - 緊急
- `priority: high` - 高優先度
- `priority: medium` - 中優先度
- `priority: low` - 低優先度

## トラブルシューティング

### gh コマンドが見つからない

GitHub CLI がインストールされていません。
上記の「GitHub CLI のインストール」セクションを参照してください。

### 認証エラー

```bash
# 再認証
gh auth login
```

### Issue が見つからない

Issue 番号を確認してください。

```bash
# Issue 一覧を表示
gh issue list

# 特定の Issue を表示
gh issue view 123
```

### スクリプトの実行権限がない

```bash
chmod +x scripts/sync-issue-to-task.sh
chmod +x scripts/update-issue-status.sh
```

## 参考資料

- [GitHub CLI ドキュメント](https://cli.github.com/manual/)
- [GitHub Issue ドキュメント](https://docs.github.com/ja/issues)
- [GitHub Issue 統合ワークフロー](./.claude/workflows/github-issue-integration.md)
