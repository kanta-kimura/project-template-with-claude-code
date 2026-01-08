# プロジェクト初期設定

新規プロジェクトを開始する際の初期設定ガイドです。

## 1. テンプレートのコピー

```bash
# このテンプレートを新しいプロジェクトディレクトリにコピー
cp -r /path/to/template /path/to/new-project
cd /path/to/new-project
```

## 2. プロジェクト情報の設定

### README.md の更新

`README.md` をプロジェクト固有の内容に更新します。

```markdown
# [プロジェクト名]

[プロジェクトの説明]

## 概要
...

## セットアップ
...
```

### LICENSE の追加

適切なライセンスファイルを追加します。

```bash
# 例: MIT License
touch LICENSE
```

## 3. 言語の選択

### 使用する言語のコーディング規約を選択

`docs/rules/coding-standards/` から使用する言語を選択します。

使用しない言語のファイルは削除しても構いません。

### 言語固有の設定ファイル

#### TypeScript/JavaScript
```bash
# package.json
npm init -y

# TypeScript設定
npm install -D typescript @types/node
npx tsc --init

# Prettier
npm install -D prettier
echo '{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5"
}' > .prettierrc
```

#### Python
```bash
# 仮想環境
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 依存関係管理
pip install -r requirements.txt

# または Poetry
poetry init
```

#### Go
```bash
# Go modules
go mod init github.com/username/project-name
```

#### Rust
```bash
# Cargo
cargo init
```

#### Java
```bash
# Maven
mvn archetype:generate

# または Gradle
gradle init
```

## 4. Git リポジトリの初期化

```bash
# Git初期化
git init

# 初回コミット
git add .
git commit -m "[chore] プロジェクト初期設定"

# リモートリポジトリの設定
git remote add origin https://github.com/username/repo.git
git branch -M main
git push -u origin main
```

## 5. .gitignore の設定

`.gitignore` ファイルを言語に合わせて更新します。

テンプレート: https://github.com/github/gitignore

## 6. プロジェクト固有設定

### 用語集の更新

`docs/rules/terminology.md` にプロジェクト固有の用語を追加します。

### コーディング規約のカスタマイズ

必要に応じて `docs/rules/coding-standards/` を修正します。

### アーキテクチャドキュメント

`docs/architecture/overview.md` にプロジェクトのアーキテクチャを記載します。

## 7. CI/CD の設定

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          # テストコマンド
```

テンプレート: `templates/ci/github-actions.yml`

### GitLab CI

テンプレート: `templates/ci/gitlab-ci.yml`

## 8. 開発環境の整備

### エディタ設定

#### VS Code
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

#### エディタ共通
```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2
```

### Pre-commit hooks

```bash
# Husky (Node.js)
npm install -D husky
npx husky install

# Pre-commit hook
npx husky add .husky/pre-commit "npm test"
```

## 9. 環境変数の設定

### .env.example の作成

```bash
# .env.example
DATABASE_URL=postgresql://localhost:5432/mydb
API_KEY=your-api-key-here
PORT=3000
NODE_ENV=development
```

### 実際の .env は .gitignore に追加

```bash
echo ".env" >> .gitignore
```

## 10. 依存関係のインストール

### TypeScript/JavaScript
```bash
npm install
```

### Python
```bash
pip install -r requirements.txt
# または
poetry install
```

### Go
```bash
go mod download
```

### Rust
```bash
cargo build
```

### Java
```bash
# Maven
mvn install

# Gradle
gradle build
```

## 11. テストの実行

```bash
# プロジェクトのテストが動作することを確認
npm test           # Node.js
pytest             # Python
go test ./...      # Go
cargo test         # Rust
mvn test           # Maven
```

## 12. ドキュメントの整備

### 最初の機能仕様を作成

```bash
cp templates/feature-spec.md docs/specs/features/initial-feature.md
```

`docs/specs/features/initial-feature.md` を編集して最初の機能を定義します。

### ADR (Architecture Decision Record) の開始

重要な設計決定を記録します。

```bash
cp templates/adr.md docs/adr/0001-use-postgresql.md
```

## 13. Claude Code の設定

### 共有コンテキストの更新

`.claude/context/api-specs.md` にプロジェクト固有のAPI仕様を記載します。

`.claude/context/interfaces.md` に共通の型定義を記載します。

### タスク管理の準備

`.claude/dashboard.md` を確認し、必要に応じてカスタマイズします。

## 14. チーム共有

### README にセットアップ手順を記載

```markdown
## セットアップ

\`\`\`bash
# リポジトリのクローン
git clone https://github.com/username/repo.git
cd repo

# 依存関係のインストール
npm install

# 環境変数の設定
cp .env.example .env
# .env を編集

# データベースのセットアップ
npm run db:migrate

# 開発サーバーの起動
npm run dev
\`\`\`
```

### コントリビューションガイド

```bash
# CONTRIBUTING.md を作成
touch CONTRIBUTING.md
```

## チェックリスト

### 初期設定
- [ ] テンプレートをコピー
- [ ] README.md を更新
- [ ] LICENSE を追加
- [ ] .gitignore を設定
- [ ] Git リポジトリを初期化

### 開発環境
- [ ] 言語固有の設定ファイルを作成
- [ ] 依存関係をインストール
- [ ] テストが実行できる
- [ ] エディタ設定を追加

### ドキュメント
- [ ] 用語集をカスタマイズ
- [ ] アーキテクチャドキュメントを作成
- [ ] 最初の機能仕様を作成

### CI/CD
- [ ] CI/CD パイプラインを設定
- [ ] Pre-commit hooks を設定

### Claude Code
- [ ] 共有コンテキストを更新
- [ ] ダッシュボードを確認

### チーム
- [ ] セットアップ手順をドキュメント化
- [ ] コントリビューションガイドを作成
- [ ] チームメンバーと共有

## トラブルシューティング

### 依存関係のインストールエラー

- Node.js のバージョンを確認
- Python のバージョンを確認
- キャッシュをクリア

### テスト実行エラー

- 環境変数が正しく設定されているか確認
- データベース接続を確認
- 必要なサービスが起動しているか確認

## 次のステップ

1. 最初の機能仕様を作成
2. 実装計画を立案（`.claude/plans/`）
3. タスクに細分化（`.claude/tasks/backlog/`）
4. 開発開始

詳細は `.claude/workflows/parallel-dev.md` を参照してください。
