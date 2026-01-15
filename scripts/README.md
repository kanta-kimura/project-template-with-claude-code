# タスク管理スクリプト

## クイックリファレンス

```bash
./scripts/task.sh list              # 一覧
./scripts/task.sh create "タイトル"  # 作成
./scripts/task.sh start <id>        # 開始
./scripts/task.sh review <id>       # レビュー依頼
./scripts/task.sh done <id>         # 完了
./scripts/task.sh show <id>         # 詳細表示
```

## モード設定

`.claude/config.yaml` で切り替え:

```yaml
task_management:
  mode: github  # GitHub Issues 使用（推奨）
  # mode: local # ローカルファイル使用（Bitbucket等）
```

## GitHub モード

GitHub Issues で直接管理。タスクファイル不要。

```bash
./scripts/task.sh list              # gh issue list
./scripts/task.sh create "タイトル"  # gh issue create
./scripts/task.sh start 123         # ラベル変更 → in-progress
./scripts/task.sh done 123          # Issue クローズ
```

## ローカルモード

`.claude/tasks/TASK-XXX.md` で管理。GitHub なし環境向け。

```bash
./scripts/task.sh list              # タスクファイル一覧
./scripts/task.sh create "タイトル"  # TASK-001.md 作成
./scripts/task.sh start TASK-001    # status: in-progress
./scripts/task.sh done TASK-001     # status: completed
```

## 前提条件

### GitHub モード

```bash
brew install gh
gh auth login
```

### 共通

```bash
chmod +x scripts/task.sh
```
