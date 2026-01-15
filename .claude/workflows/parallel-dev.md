# 並列開発ガイド

複数の Claude Code インスタンスで並列開発を行うためのガイドラインです。

## セットアップ

### 1. インスタンスの起動
複数のターミナルで Claude Code を起動します。

```bash
# ターミナル1
cd /path/to/project
claude

# ターミナル2
cd /path/to/project
claude

# ターミナル3
cd /path/to/project
claude
```

### 2. インスタンス名の設定
各インスタンスに識別可能な名前を付けます。

```
例:
- claude-auth (認証機能担当)
- claude-api (API実装担当)
- claude-ui (UI実装担当)
- claude-reviewer (レビュー担当)
```

## ワークフロー

### タスク取得フロー

1. **Backlog確認**
   ```bash
   # backlog ディレクトリを確認
   ls .claude/tasks/backlog/

   # または GitHub Issue から未着手タスクを確認
   gh issue list --label "status: backlog"
   ```

2. **依存関係チェック**
   ```bash
   # dependencies.yaml で依存タスクが完了しているか確認
   cat .claude/tasks/dependencies.yaml
   ```

3. **GitHub Issue 登録（未登録の場合）**
   ```bash
   # タスクファイルから GitHub Issue を作成
   ./scripts/create-issue-from-task.sh TASK-XXX
   ```

4. **タスク移動**
   ```bash
   # タスクファイルを in-progress に移動
   mv .claude/tasks/backlog/TASK-XXX.md .claude/tasks/in-progress/[instance-name]/
   ```

5. **GitHub Issue ステータス更新**
   ```bash
   # Issue のステータスラベルを in-progress に変更
   gh issue edit <issue-number> --add-label "status: in-progress" --remove-label "status: backlog"
   ```

6. **ダッシュボード更新**
   ```bash
   # .claude/dashboard.md の「実装中タスク」セクションを更新
   # - 最終更新日時を更新
   # - 全体サマリーの件数を更新
   # - 実装中タスクテーブルに追加
   ```

### 実装フロー

1. **コンテキスト確認**
   ```bash
   # 共有情報を確認
   cat .claude/context/api-specs.md
   cat .claude/context/interfaces.md
   ```

2. **実装**
   ```
   タスクに記載された要件に従って実装
   ```

3. **セルフレビュー**
   ```
   以下を確認:
   - コーディング規約準拠
   - セキュリティチェックリスト
   - テストカバレッジ
   ```

4. **コミット（Issue 参照）**
   ```bash
   # コミット時に Issue を参照
   git commit -m "[feat] 機能を実装

   Refs #<issue-number>"
   ```

5. **タスク移動**
   ```bash
   # タスクファイルを review に移動
   mv .claude/tasks/in-progress/[instance-name]/TASK-XXX.md .claude/tasks/review/
   ```

6. **GitHub Issue ステータス更新**
   ```bash
   # Issue のステータスラベルを review に変更
   gh issue edit <issue-number> --add-label "status: review" --remove-label "status: in-progress"
   ```

7. **ダッシュボード更新**
   ```bash
   # .claude/dashboard.md の更新
   # - 最終更新日時を更新
   # - 全体サマリーの件数を更新
   # - 実装中タスクから削除
   # - レビュー待ちタスクに追加
   ```

### レビュー完了フロー

1. **レビュー承認後、タスク移動**
   ```bash
   # タスクファイルを completed に移動
   mv .claude/tasks/review/TASK-XXX.md .claude/tasks/completed/
   ```

2. **GitHub Issue クローズ**
   ```bash
   # Issue をクローズ
   gh issue close <issue-number> --comment "実装完了。レビュー承認されました。"
   ```

3. **ダッシュボード更新**
   ```bash
   # .claude/dashboard.md の更新
   # - 最終更新日時を更新
   # - 全体サマリーの件数を更新
   # - レビュー待ちタスクから削除
   # - 完了タスク（直近10件）に追加
   # - 進捗グラフを更新
   ```

## 競合の回避

### ファイルレベルの分離
異なるインスタンスは異なるファイルを編集するように計画します。

**推奨:**
- インスタンスA: `src/auth/login.ts`
- インスタンスB: `src/api/users.ts`

**非推奨:**
- インスタンスA: `src/utils/helpers.ts` の関数A
- インスタンスB: `src/utils/helpers.ts` の関数B
  → 同じファイルを編集すると競合リスク

### 共通コードの扱い

**インターフェース定義は先に作成**
```typescript
// 先に interfaces.ts を作成
export interface User {
  id: string;
  name: string;
}

// その後、並列で実装
// instance-A: UserRepository
// instance-B: UserService
```

**共通ユーティリティは専用タスクで**
```
タスク分割例:
- TASK-001: 共通ユーティリティ実装 (先に実施)
- TASK-002: 機能A実装 (ユーティリティ利用)
- TASK-003: 機能B実装 (ユーティリティ利用)
```

## コミュニケーション

### .claude/context/ の活用

**インスタンス間の情報共有**
```
.claude/context/ に共有情報を追加:
- 新しいAPIエンドポイントを追加した
- 共通型定義を変更した
- 環境変数を追加した
```

### ダッシュボードの確認
定期的に `.claude/dashboard.md` を確認し、他のインスタンスの進捗を把握します。

## ベストプラクティス

### 1. 小さく頻繁にコミット
実装途中でも意味のある単位でコミットします。

```bash
git add src/auth/login.ts
git commit -m "[feat] ログイン機能の基本実装"
```

### 2. ブランチ戦略
各タスクを個別のブランチで実装します。

```bash
git checkout -b task/TASK-001-auth-login
```

### 3. Pull前の確認
他のインスタンスの変更を取り込む前に、自分の変更をコミットします。

```bash
git status
git add .
git commit -m "[feat] 実装完了"
git pull origin main
```

### 4. 競合発生時
競合が発生した場合、以下の優先順位で解決します:

1. タスクの依存関係を確認
2. 後続タスクが先行タスクの変更を取り込む
3. 必要に応じて調整タスクを作成

## トラブルシューティング

### Q: 同じファイルを編集する必要がある
**A:** タスクを再分割するか、依存関係を設定して順次実行に変更

### Q: 他のインスタンスの進捗が分からない
**A:** `.claude/dashboard.md` を確認、または直接確認

### Q: 依存タスクが完了していない
**A:** 別の独立したタスクを実施するか、依存タスクの完了を待つ

### Q: 共通コードを変更したい
**A:** 別途調整タスクを作成し、影響範囲を明確にする

## チェックリスト

### タスク開始前
- [ ] `dependencies.yaml` で依存タスクが完了している
- [ ] 同じファイルを編集する他のタスクがない
- [ ] `.claude/context/` の共有情報を確認した
- [ ] GitHub Issue が登録されている（未登録の場合は作成）
- [ ] タスクファイルを `in-progress/[instance-name]/` に移動した
- [ ] GitHub Issue のステータスを `in-progress` に更新した
- [ ] `.claude/dashboard.md` を更新した

### タスク完了時（レビュー依頼）
- [ ] コーディング規約を確認した
- [ ] テストを実装・実行した
- [ ] コミットメッセージに Issue 番号を参照した（`Refs #XXX`）
- [ ] タスクファイルを `review/` に移動した
- [ ] GitHub Issue のステータスを `review` に更新した
- [ ] `.claude/dashboard.md` を更新した
- [ ] 必要に応じて `.claude/context/` を更新した

### レビュー完了時
- [ ] タスクファイルを `completed/` に移動した
- [ ] GitHub Issue をクローズした
- [ ] `.claude/dashboard.md` を更新した
