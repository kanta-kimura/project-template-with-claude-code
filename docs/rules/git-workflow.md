# Git運用ルール

プロジェクトにおけるGitの運用ルールです。

## ブランチ戦略

### ブランチ構成

```
main (または master)
├── develop
├── feature/[feature-name]
├── bugfix/[bug-name]
├── hotfix/[hotfix-name]
└── release/[version]
```

### ブランチの役割

#### main / master
- 本番環境にデプロイ可能な状態を常に保つ
- 直接コミットは禁止
- マージはプルリクエスト経由のみ

#### develop
- 開発の中心ブランチ
- 次のリリースに含まれる機能を統合
- feature ブランチのマージ先

#### feature/[feature-name]
- 新機能開発用
- develop からブランチを作成
- 完了後は develop にマージ

命名例:
```
feature/user-authentication
feature/payment-integration
feature/admin-dashboard
```

#### bugfix/[bug-name]
- バグ修正用
- develop からブランチを作成
- 完了後は develop にマージ

命名例:
```
bugfix/login-error
bugfix/payment-validation
```

#### hotfix/[hotfix-name]
- 本番環境の緊急修正用
- main からブランチを作成
- 完了後は main と develop の両方にマージ

命名例:
```
hotfix/security-patch
hotfix/critical-bug-fix
```

#### release/[version]
- リリース準備用
- develop からブランチを作成
- バージョン番号の更新、ドキュメント整備
- 完了後は main と develop にマージ

命名例:
```
release/v1.0.0
release/v1.2.0
```

## コミット

### コミットメッセージ

グローバル設定(`~/.claude/CLAUDE.md`)で定義されたフォーマットに従います。

**基本形式:**
```
[prefix] タイトル（50文字以内）

詳細な説明（必要に応じて）
- 変更の理由
- 影響範囲
- 関連Issue

Refs #123
```

**prefix の種類:**
- `[feat]`: 新機能
- `[fix]`: バグ修正
- `[docs]`: ドキュメント変更
- `[style]`: コードフォーマット変更
- `[refactor]`: リファクタリング
- `[perf]`: パフォーマンス改善
- `[test]`: テスト追加・修正
- `[chore]`: ビルド・設定変更

**例:**
```
[feat] ユーザー認証機能を追加

JWT トークンベースの認証システムを実装。
セッションベースから移行することで、スケーラビリティを向上。

- ログイン/ログアウトエンドポイントを追加
- トークンのリフレッシュ機能を実装
- 認証ミドルウェアを作成

Refs #123
```

### コミットの粒度

**1コミット1機能**を守ります。

✅ 良い例:
```bash
git commit -m "[feat] ユーザーモデルを追加"
git commit -m "[feat] ユーザー登録APIを実装"
git commit -m "[test] ユーザー登録のテストを追加"
```

❌ 悪い例:
```bash
git commit -m "[feat] ユーザー機能を実装"  # 大きすぎる
```

### コミット前のチェック

```bash
# 変更内容を確認
git status
git diff

# 必要なファイルのみステージング
git add src/user.ts
git add tests/user.test.ts

# コミット
git commit -m "[feat] ユーザーモデルを追加"
```

## プルリクエスト

### 作成前の確認

- [ ] すべてのテストが成功
- [ ] コーディング規約に準拠
- [ ] コンフリクトが解決済み
- [ ] コミットメッセージが適切
- [ ] 機密情報が含まれていない

### PRテンプレート

```markdown
## 概要
この PR は [機能/修正] を実装します。

## 変更内容
- 変更1
- 変更2
- 変更3

## 関連Issue
Closes #123

## テスト
- [ ] 単体テスト追加
- [ ] 統合テスト追加
- [ ] 手動テスト実施

## スクリーンショット（該当する場合）
[画像を添付]

## チェックリスト
- [ ] テストが成功している
- [ ] ドキュメントを更新した
- [ ] コーディング規約に準拠
- [ ] breaking change がない（またはドキュメント化済み）
```

### レビュー

- レビュアーは1名以上必須
- すべてのコメントに対応してからマージ
- レビューガイドラインは `.claude/reviews/guidelines.md` を参照

### マージ

**マージ方法:**
- feature → develop: Squash and merge
- develop → main: Merge commit
- hotfix → main: Merge commit

```bash
# feature ブランチの作業完了後
git checkout develop
git pull origin develop
git merge --squash feature/user-auth
git commit -m "[feat] ユーザー認証機能を追加"
git push origin develop
```

## 履歴管理

### リベース vs マージ

**リベース（feature ブランチ内の整理）:**
```bash
# feature ブランチ内でコミットを整理
git rebase -i HEAD~3
```

**マージ（ブランチ統合）:**
```bash
# develop を feature に取り込む
git checkout feature/user-auth
git merge develop
```

### コミットの修正

**最新コミットの修正:**
```bash
# まだ push していない場合のみ
git commit --amend
```

**過去のコミット修正:**
```bash
# まだ push していない場合のみ
git rebase -i HEAD~3
# エディタで 'pick' を 'edit' に変更
```

⚠️ **注意**: push 済みのコミットは修正しない

## タグ

### バージョンタグ

セマンティックバージョニングを使用します。

```
v[MAJOR].[MINOR].[PATCH]

例:
v1.0.0  # 初回リリース
v1.1.0  # 機能追加
v1.1.1  # バグ修正
v2.0.0  # breaking change
```

**タグの作成:**
```bash
# アノテーション付きタグ
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## .gitignore

プロジェクトルートの `.gitignore` ファイルを使用します。

**基本的な除外対象:**
- ビルド成果物
- 依存関係（node_modules, venv など）
- IDE設定ファイル
- 環境変数ファイル（.env）
- ログファイル
- 一時ファイル

## トラブルシューティング

### コンフリクト解決

```bash
# コンフリクト発生
git merge develop

# コンフリクトファイルを確認
git status

# ファイルを編集してコンフリクトを解決
# <<<<<<< HEAD と ======= と >>>>>>> develop を削除

# 解決済みとしてマーク
git add [resolved-file]

# マージを完了
git commit
```

### 誤ってコミットした場合

```bash
# まだ push していない場合
git reset --soft HEAD~1  # コミットを取り消し、変更は保持
git reset --hard HEAD~1  # コミットと変更を両方取り消し

# push済みの場合は revert
git revert HEAD
git push origin [branch]
```

### 間違ったブランチにコミットした場合

```bash
# コミットを別のブランチに移動
git log  # コミットIDを確認
git checkout correct-branch
git cherry-pick [commit-id]

# 元のブランチから削除
git checkout wrong-branch
git reset --hard HEAD~1
```

## ベストプラクティス

### こまめなコミット
- 意味のある単位で頻繁にコミット
- 大きな変更を小さく分割

### 頻繁なプル
- 作業開始前に必ず最新状態に更新
```bash
git checkout develop
git pull origin develop
```

### ブランチの削除
- マージ済みのブランチは削除
```bash
git branch -d feature/user-auth
git push origin --delete feature/user-auth
```

### コミット前の確認
```bash
git diff          # 変更内容を確認
git status        # ステータス確認
git log --oneline # コミット履歴確認
```

## 禁止事項

- [ ] main ブランチへの直接コミット
- [ ] force push（特に共有ブランチへの）
- [ ] 大きすぎるファイルのコミット（バイナリ、動画など）
- [ ] 機密情報のコミット（パスワード、APIキー）
- [ ] 意味のないコミットメッセージ（"fix", "update" など）
- [ ] コミットの改変（push 済みの場合）

## チェックリスト

### ブランチ作成時
- [ ] 適切なブランチ名を使用
- [ ] develop から最新の状態で作成

### コミット時
- [ ] 変更内容を確認
- [ ] 適切なコミットメッセージ
- [ ] 機密情報が含まれていない

### プルリクエスト作成時
- [ ] すべてのテストが成功
- [ ] コンフリクトが解決済み
- [ ] 説明が明確
- [ ] レビュアーを指定

### マージ時
- [ ] レビュー承認済み
- [ ] すべてのコメントに対応済み
- [ ] CI/CDが成功
