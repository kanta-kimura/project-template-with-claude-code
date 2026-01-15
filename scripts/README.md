# スクリプト集

プロジェクト管理を効率化するためのスクリプト集です。
すべてのスクリプトは GitHub CLI (`gh`) を使用します。

## クイックリファレンス

```bash
# タスク → Issue 登録
./scripts/create-issue-from-task.sh TASK-001

# Issue → タスク生成
./scripts/sync-issue-to-task.sh 123

# タスク移動（一括処理：移動 + Issue更新 + ダッシュボード更新）
./scripts/move-task.sh TASK-001 in-progress claude-1
./scripts/move-task.sh TASK-001 review
./scripts/move-task.sh TASK-001 completed

# Issue ステータス更新のみ
./scripts/update-issue-status.sh 123 in-progress

# ダッシュボード更新のみ
./scripts/update-dashboard.sh
```

## スクリプト一覧

### move-task.sh（推奨）

**タスク移動の一括処理スクリプト。** 以下を自動で実行します：
1. タスクファイルの移動
2. GitHub Issue のステータス更新
3. ダッシュボードの自動更新

```bash
# 使い方
./scripts/move-task.sh <task-id> <target-status> [instance-name]

# タスクを開始（instance-name 必須）
./scripts/move-task.sh TASK-001 in-progress claude-1

# レビュー依頼
./scripts/move-task.sh TASK-001 review

# タスク完了
./scripts/move-task.sh TASK-001 completed

# バックログに戻す
./scripts/move-task.sh TASK-001 backlog
```

### create-issue-from-task.sh

タスクファイルから GitHub Issue を作成します。

```bash
# 使い方
./scripts/create-issue-from-task.sh <task-id>

# 例
./scripts/create-issue-from-task.sh TASK-001
```

**処理内容:**
1. タスクファイルからタイトルと内容を読み取り
2. `gh issue create` で Issue を作成
3. タスクファイルに Issue 番号を追記

### sync-issue-to-task.sh

GitHub Issue からタスクファイルを生成します。

```bash
# 使い方
./scripts/sync-issue-to-task.sh <issue-number>

# 例
./scripts/sync-issue-to-task.sh 123
```

**処理内容:**
1. `gh issue view` で Issue 情報を取得
2. `.claude/tasks/backlog/TASK-{number}.md` を生成
3. Issue の内容をタスクファイルに変換

### update-issue-status.sh

GitHub Issue のステータスラベルを更新します。

```bash
# 使い方
./scripts/update-issue-status.sh <issue-number> <new-status>

# 例
./scripts/update-issue-status.sh 123 in-progress
./scripts/update-issue-status.sh 123 review
./scripts/update-issue-status.sh 123 completed
```

**利用可能なステータス:**
- `backlog` - 未着手
- `in-progress` - 実装中
- `review` - レビュー中
- `blocked` - ブロック中
- `completed` - 完了

### update-dashboard.sh

ダッシュボードを自動更新します。

```bash
# 使い方
./scripts/update-dashboard.sh
```

**処理内容:**
1. `.claude/tasks/` ディレクトリをスキャン
2. タスク状況を集計
3. `.claude/dashboard.md` を再生成
4. 競合を避けるためロックファイルを使用

## 完全なワークフロー

### 1. タスク作成 → Issue 登録 → 開始

```bash
# タスクファイルを作成後、Issue 登録 & タスク開始を一括実行
./scripts/create-issue-from-task.sh TASK-001
./scripts/move-task.sh TASK-001 in-progress claude-1
```

### 2. Issue から始める場合

```bash
# Issue を検索
gh issue list --label "status: backlog"

# Issue からタスクファイル生成 & タスク開始を一括実行
./scripts/sync-issue-to-task.sh 123
./scripts/move-task.sh TASK-123 in-progress claude-1
```

### 3. 実装

```bash
# コミット時は Issue を参照
git commit -m "[feat] 機能実装

Refs #123"
```

### 4. レビュー依頼

```bash
# 一括実行：ファイル移動 + Issue更新 + ダッシュボード更新
./scripts/move-task.sh TASK-123 review

# PR を作成（Issue を自動クローズ）
gh pr create --title "機能実装" --body "Closes #123"
```

### 5. 完了

```bash
# 一括実行：ファイル移動 + Issue クローズ + ダッシュボード更新
./scripts/move-task.sh TASK-123 completed
```

## 前提条件

### GitHub CLI のインストール

```bash
# macOS
brew install gh

# Linux
sudo apt install gh

# Windows
winget install GitHub.cli
```

### 認証

```bash
gh auth login
```

### スクリプトの実行権限

```bash
chmod +x scripts/*.sh
```

## gh CLI コマンドリファレンス

```bash
# Issue 一覧を表示
gh issue list
gh issue list --label "status: backlog"

# Issue を表示
gh issue view <number>

# Issue を作成
gh issue create --title "タイトル" --label "feature" --body "内容"

# Issue のラベルを変更
gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"

# Issue をクローズ
gh issue close <number> --comment "完了コメント"

# PR を作成
gh pr create --title "タイトル" --body "Closes #123"
```

## トラブルシューティング

### gh コマンドが見つからない

GitHub CLI がインストールされていません。上記「前提条件」を参照してください。

### 認証エラー

```bash
gh auth login
```

### ロックファイルエラー

別のプロセスが更新中の可能性があります。

```bash
# 手動でロック解除（他のプロセスが完了していることを確認後）
rm .claude/.dashboard.lock
```

### タスクファイルが見つからない

タスクIDを確認してください。

```bash
# タスクファイルを検索
find .claude/tasks -name "TASK-*.md"
```
