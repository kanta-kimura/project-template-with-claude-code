# タスク管理クイックリファレンス

## コマンド

```bash
./scripts/task.sh list              # 一覧
./scripts/task.sh create "タイトル"  # 作成
./scripts/task.sh start <id>        # 開始
./scripts/task.sh review <id>       # レビュー依頼
./scripts/task.sh done <id>         # 完了
```

## モード

`.claude/config.yaml` の `task_management.mode` で切替:

- `github`: GitHub Issues 使用（推奨）
- `local`: `.claude/tasks/TASK-XXX.md` ファイル使用

## ステータス遷移

```
backlog → in-progress → review → completed
```

## ローカルモードのタスクファイル

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
