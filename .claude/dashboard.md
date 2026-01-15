# プロジェクト進捗ダッシュボード

最終更新: 未設定

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

<!-- 例:
| タスクID | タイトル | 担当インスタンス | 開始日時 | Issue |
|---------|---------|----------------|----------|-------|
| TASK-001 | ユーザー認証機能 | claude-1 | 2025-01-08 10:00 | #123 |
-->

## 👀 レビュー待ちタスク

レビュー待ちのタスクはありません。

<!-- 例:
| タスクID | タイトル | 実装完了日時 | レビュアー | Issue |
|---------|---------|-------------|-----------|-------|
| TASK-002 | データベース設計 | 2025-01-08 12:00 | claude-reviewer-1 | #124 |
-->

## 📋 Backlog

未着手のタスクはありません。

<!-- 例:
| タスクID | タイトル | 優先度 | 依存タスク | Issue |
|---------|---------|-------|-----------|-------|
| TASK-003 | API実装 | High | TASK-001 | #125 |
| TASK-004 | UI実装 | Medium | TASK-003 | #126 |
-->

## ✅ 完了タスク（直近10件）

完了したタスクはありません。

<!-- 例:
| タスクID | タイトル | 完了日時 | 担当インスタンス | Issue |
|---------|---------|---------|----------------|-------|
| TASK-000 | プロジェクト初期設定 | 2025-01-08 09:00 | claude-setup | #120 |
-->

## 📈 進捗グラフ

```
進捗: [----------] 0%
```

---

## 使い方

このファイルは各 Claude Code インスタンスが自動更新します。

### タスク開始時（backlog → in-progress）

**必須操作:**
1. `backlog/` からタスクを取得
2. `in-progress/[instance-name]/` に移動
3. GitHub Issue のステータスを更新: `gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"`

**ダッシュボード更新:**
```
□ 最終更新日時を現在日時に更新
□ 全体サマリー: 未着手 -1、実装中 +1
□ 「実装中タスク」テーブルに追加:
  | TASK-XXX | タイトル | [instance-name] | YYYY-MM-DD HH:MM | #Issue番号 |
□ 「Backlog」テーブルから該当タスクを削除
```

### レビュー依頼時（in-progress → review）

**必須操作:**
1. `in-progress/[instance-name]/` から `review/` に移動
2. GitHub Issue のステータスを更新: `gh issue edit <number> --add-label "status: review" --remove-label "status: in-progress"`

**ダッシュボード更新:**
```
□ 最終更新日時を現在日時に更新
□ 全体サマリー: 実装中 -1、レビュー中 +1
□ 「実装中タスク」テーブルから該当タスクを削除
□ 「レビュー待ちタスク」テーブルに追加:
  | TASK-XXX | タイトル | YYYY-MM-DD HH:MM | - | #Issue番号 |
```

### 完了時（review → completed）

**必須操作:**
1. `review/` から `completed/` に移動
2. GitHub Issue をクローズ: `gh issue close <number> --comment "実装完了"`

**ダッシュボード更新:**
```
□ 最終更新日時を現在日時に更新
□ 全体サマリー: レビュー中 -1、完了 +1
□ 「レビュー待ちタスク」テーブルから該当タスクを削除
□ 「完了タスク」テーブルに追加（直近10件を保持）:
  | TASK-XXX | タイトル | YYYY-MM-DD HH:MM | [instance-name] | #Issue番号 |
□ 進捗グラフを更新（完了数 / 合計数）
```

### 更新方法
- 各セクションのコメント例を参考に、テーブル形式で記載
- **最終更新日時を必ず更新**
- **全体サマリーの数値も更新**
- **GitHub Issue 番号をテーブルに含める**（リンク形式: `#番号`）

### gh CLI コマンド

```bash
# Issue ステータスを in-progress に変更
gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"

# Issue ステータスを review に変更
gh issue edit <number> --add-label "status: review" --remove-label "status: in-progress"

# Issue をクローズ
gh issue close <number> --comment "実装完了。レビュー承認されました。"
```
