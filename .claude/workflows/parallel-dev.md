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
   ```
   .claude/tasks/backlog/ を確認
   ```

2. **依存関係チェック**
   ```
   .claude/tasks/dependencies.yaml で依存タスクが完了しているか確認
   ```

3. **タスク移動**
   ```
   backlog/TASK-XXX.md → in-progress/[instance-name]/TASK-XXX.md
   ```

4. **ダッシュボード更新**
   ```
   .claude/dashboard.md の「実装中タスク」セクションを更新
   ```

### 実装フロー

1. **コンテキスト確認**
   ```
   .claude/context/ の共有情報を確認
   - api-specs.md: API仕様
   - interfaces.md: 共通インターフェース
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

4. **タスク移動**
   ```
   in-progress/[instance-name]/TASK-XXX.md → review/TASK-XXX.md
   ```

5. **ダッシュボード更新**
   ```
   .claude/dashboard.md を更新
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

タスク開始前:
- [ ] `dependencies.yaml` で依存タスクが完了している
- [ ] 同じファイルを編集する他のタスクがない
- [ ] `.claude/context/` の共有情報を確認した
- [ ] ダッシュボードを更新した

タスク完了時:
- [ ] コーディング規約を確認した
- [ ] テストを実装・実行した
- [ ] コミットメッセージが適切
- [ ] ダッシュボードを更新した
- [ ] 必要に応じて `.claude/context/` を更新した
