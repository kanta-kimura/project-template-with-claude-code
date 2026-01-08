# CI/CD テンプレート

このディレクトリには、各種CI/CDツールの設定テンプレートが含まれています。

## 利用可能なテンプレート

- `github-actions.yml`: GitHub Actions の設定例
- `gitlab-ci.yml`: GitLab CI の設定例

## 使い方

### GitHub Actions

1. `.github/workflows/` ディレクトリを作成
   ```bash
   mkdir -p .github/workflows
   ```

2. テンプレートをコピー
   ```bash
   cp templates/ci/github-actions.yml .github/workflows/ci.yml
   ```

3. プロジェクトに合わせて編集
   - ビルドコマンド
   - テストコマンド
   - デプロイ設定
   - 環境変数

### GitLab CI

1. プロジェクトルートにコピー
   ```bash
   cp templates/ci/gitlab-ci.yml .gitlab-ci.yml
   ```

2. プロジェクトに合わせて編集

## 共通の設定項目

### ビルド

プロジェクトのビルドコマンドを設定します。

```yaml
# 例（Node.js）
- npm install
- npm run build

# 例（Python）
- pip install -r requirements.txt
- python setup.py build

# 例（Go）
- go mod download
- go build
```

### テスト

テスト実行とカバレッジ測定を設定します。

```yaml
# 例（Node.js）
- npm test
- npm run test:coverage

# 例（Python）
- pytest --cov=src tests/
- coverage report

# 例（Go）
- go test ./...
- go test -coverprofile=coverage.out
```

### リンター

コード品質チェックを設定します。

```yaml
# 例（Node.js/TypeScript）
- npm run lint
- npm run type-check

# 例（Python）
- ruff check .
- mypy src/

# 例（Go）
- golangci-lint run
```

### セキュリティスキャン

脆弱性チェックを設定します。

```yaml
# 例（Node.js）
- npm audit

# 例（Python）
- pip-audit

# 例（Go）
- go list -json -m all | nancy sleuth
```

## ブランチ戦略との統合

### main / master ブランチ

本番環境へのデプロイを実行します。

```yaml
on:
  push:
    branches: [main, master]
```

### develop ブランチ

ステージング環境へのデプロイを実行します。

```yaml
on:
  push:
    branches: [develop]
```

### feature ブランチ

ビルドとテストのみ実行します。

```yaml
on:
  pull_request:
    branches: [develop, main]
```

## 環境変数の設定

### GitHub Actions

1. リポジトリの Settings → Secrets → Actions
2. 環境変数を追加

### GitLab CI

1. プロジェクトの Settings → CI/CD → Variables
2. 環境変数を追加

### 必要な環境変数の例

```
# データベース
DATABASE_URL=postgresql://...

# API キー
API_KEY=...

# デプロイ設定
DEPLOY_HOST=...
DEPLOY_USER=...
DEPLOY_KEY=...
```

## キャッシュ設定

ビルド時間を短縮するためのキャッシュ設定例。

### Node.js

```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Python

```yaml
- name: Cache pip
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Go

```yaml
- name: Cache Go modules
  uses: actions/cache@v3
  with:
    path: ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```

## デプロイ設定

### SSH デプロイ

```yaml
- name: Deploy via SSH
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    key: ${{ secrets.DEPLOY_KEY }}
    script: |
      cd /path/to/app
      git pull
      npm install
      npm run build
      pm2 restart app
```

### Docker デプロイ

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v4
  with:
    push: true
    tags: user/app:latest
```

## 通知設定

### Slack 通知

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build completed'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

## トラブルシューティング

### ビルドが失敗する

1. ローカルで同じコマンドを実行して確認
2. 環境変数が正しく設定されているか確認
3. 依存関係が正しくインストールされているか確認

### テストが失敗する

1. ローカルでテストを実行して確認
2. テストデータベースの設定を確認
3. タイムゾーンや環境依存の問題を確認

### デプロイが失敗する

1. SSH接続が正しいか確認
2. デプロイ先のディスク容量を確認
3. デプロイスクリプトの権限を確認

## ベストプラクティス

1. **小さく頻繁にコミット**: CI/CDが素早く実行される
2. **テストの並列化**: 実行時間を短縮
3. **キャッシュの活用**: ビルド時間を短縮
4. **失敗時の通知**: 問題を素早く把握
5. **ステージング環境**: 本番デプロイ前に検証

## 参考資料

- [GitHub Actions ドキュメント](https://docs.github.com/ja/actions)
- [GitLab CI ドキュメント](https://docs.gitlab.com/ee/ci/)
- [CI/CD ベストプラクティス](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)
