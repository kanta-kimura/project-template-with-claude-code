# プロジェクト進捗ダッシュボード

最終更新: 2026-01-15 11:05:56

## 📊 全体サマリー

| ステータス | 件数 | 割合 |
|-----------|------|------|
| 完了 | 0 | 0% |
| レビュー中 | 0 | 0% |
| 実装中 | 0 | 0% |
| 未着手 | 0 | 0% |
| **合計** | **0** | **100%** |

## 🚀 実装中タスク

現在実装中のタスクはありません。

## 👀 レビュー待ちタスク

レビュー待ちのタスクはありません。

## 📋 Backlog

未着手のタスクはありません。

## ✅ 完了タスク（直近10件）

完了したタスクはありません。

## 📈 進捗グラフ

```
進捗: [░░░░░░░░░░] 0%
```

---

## 使い方

このファイルは `./scripts/update-dashboard.sh` で自動更新されます。

### 手動更新
```bash
./scripts/update-dashboard.sh
```

### タスク移動時の自動更新
```bash
# タスク移動スクリプトを使用すると自動的にダッシュボードも更新されます
./scripts/move-task.sh TASK-XXX in-progress
./scripts/move-task.sh TASK-XXX review
./scripts/move-task.sh TASK-XXX completed
```

### gh CLI コマンド

```bash
# Issue ステータスを in-progress に変更
gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"

# Issue ステータスを review に変更
gh issue edit <number> --add-label "status: review" --remove-label "status: in-progress"

# Issue をクローズ
gh issue close <number> --comment "実装完了。レビュー承認されました。"
```
