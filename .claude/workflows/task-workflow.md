# タスク管理ワークフロー

## モード選択

`.claude/config.yaml` でモードを切り替えます。

```yaml
task_management:
  mode: github  # または local
```

## GitHub モード（推奨）

GitHub Issues を直接管理。タスクファイル不要。

```bash
./scripts/task.sh list              # Issue 一覧
./scripts/task.sh create "タイトル"  # Issue 作成
./scripts/task.sh start 123         # 開始（in-progress）
./scripts/task.sh review 123        # レビュー依頼
./scripts/task.sh done 123          # Issue クローズ
```

### ステータスラベル

- `status: backlog` - 未着手
- `status: in-progress` - 実装中
- `status: review` - レビュー中

### コミット時の Issue 参照

```bash
git commit -m "[feat] 機能を実装 Refs #123"
```

## ローカルモード

`.claude/tasks/TASK-XXX.md` でステータス管理。GitHub なし環境向け。

```bash
./scripts/task.sh list              # タスク一覧
./scripts/task.sh create "タイトル"  # TASK-001.md 作成
./scripts/task.sh start TASK-001    # status: in-progress
./scripts/task.sh review TASK-001   # status: review
./scripts/task.sh done TASK-001     # status: completed
```

### タスクファイル形式

```yaml
---
id: TASK-001
status: backlog
assignee:
---

# タスク名

## 概要
## 要件
## 依存
## メモ
```

## 並列開発

複数の Claude Code インスタンスが独立したタスクを同時に実行できます。

### 競合回避

- **異なるファイル**を編集するタスクを選択
- **依存関係**がないタスクを優先
- 共通コードは先に実装し、その後並列化

### ブランチ戦略

```bash
git checkout -b task/TASK-001-feature-name
# 実装...
git push origin task/TASK-001-feature-name
gh pr create --title "機能実装" --body "Closes #123"
```

## gh CLI セットアップ

```bash
brew install gh
gh auth login
chmod +x scripts/task.sh
```
