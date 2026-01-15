# プロジェクトテンプレート

複数言語対応の汎用プロジェクトテンプレートです。Claude Code を活用した並列開発・自動レビューワークフローに対応しています。

## ディレクトリ構成

```
/
├── README.md                   # このファイル
├── .gitignore                  # Git除外設定
│
├── .github/                    # GitHub 設定
│   └── ISSUE_TEMPLATE/         # Issue テンプレート
│       ├── feature.yml         # 機能リクエスト
│       ├── bug.yml             # バグレポート
│       └── epic.yml            # Epic Issue
│
├── scripts/                    # プロジェクト管理スクリプト
│   ├── sync-issue-to-task.sh  # Issue → タスクファイル生成
│   ├── update-issue-status.sh # Issue ステータス更新
│   └── README.md              # スクリプト使用方法
│
├── .claude/                    # Claude Code 作業ディレクトリ
│   ├── tasks/                  # タスク管理
│   │   ├── backlog/            # 実装待ちタスク（細分化済み）
│   │   ├── in-progress/        # 実装中タスク（Claude担当者別）
│   │   ├── review/             # レビュー待ちタスク
│   │   ├── completed/          # 完了タスク
│   │   └── dependencies.yaml   # タスク間の依存関係定義
│   │
│   ├── plans/                  # 実装計画書
│   │   └── [feature-name].md  # 機能ごとの実装計画
│   │
│   ├── reviews/                # レビュー記録
│   │   ├── guidelines.md       # レビューガイドライン
│   │   └── [date]-[task-id].md # レビュー記録
│   │
│   ├── workflows/              # ワークフロー定義
│   │   ├── task-breakdown.md   # タスク細分化ルール
│   │   ├── parallel-dev.md     # 並列開発ガイド
│   │   ├── review-process.md   # レビュープロセス
│   │   └── github-issue-integration.md # GitHub Issue統合
│   │
│   ├── context/                # 全インスタンス共有情報
│   │   ├── api-specs.md        # API仕様
│   │   └── interfaces.md       # 共通インターフェース定義
│   │
│   └── dashboard.md            # 全タスクの進捗状況一覧
│
├── docs/                       # プロジェクトドキュメント
│   ├── specs/                  # 機能仕様書
│   │   ├── README.md           # 仕様書の書き方
│   │   └── features/           # 機能ごとの仕様
│   │       └── [feature-name].md
│   │
│   ├── rules/                  # プロジェクトルール
│   │   ├── coding-standards/   # コーディング規約
│   │   │   ├── README.md       # 規約の適用方法
│   │   │   ├── typescript.md   # TypeScript規約
│   │   │   ├── python.md       # Python規約
│   │   │   ├── go.md           # Go規約
│   │   │   ├── rust.md         # Rust規約
│   │   │   ├── java.md         # Java規約
│   │   │   └── swift.md        # Swift規約
│   │   │
│   │   ├── terminology.md      # 用語集・命名規則
│   │   ├── git-workflow.md     # Git運用ルール
│   │   ├── project-setup.md    # プロジェクト初期設定
│   │   ├── testing-policy.md   # テスト戦略・カバレッジ基準
│   │   └── security.md         # セキュリティガイドライン
│   │
│   ├── architecture/           # アーキテクチャドキュメント
│   │   ├── overview.md         # アーキテクチャ概要
│   │   ├── design-principles.md # 設計原則
│   │   └── diagrams/           # アーキテクチャ図
│   │
│   └── adr/                    # Architecture Decision Records
│       ├── README.md           # ADRの書き方
│       └── NNNN-[title].md     # 各ADR
│
└── templates/                  # テンプレートファイル
    ├── feature-spec.md         # 機能仕様書テンプレート
    ├── implementation-plan.md  # 実装計画書テンプレート
    ├── task.md                 # タスクテンプレート
    ├── review.md               # レビュー記録テンプレート
    ├── adr.md                  # ADRテンプレート
    └── ci/                     # CI/CD テンプレート
        ├── github-actions.yml  # GitHub Actions設定例
        ├── gitlab-ci.yml       # GitLab CI設定例
        └── README.md           # CI/CD設定ガイド
```

## Claude Code 並列開発ワークフロー

### 1. 機能仕様作成
`docs/specs/features/` に機能仕様を作成します。

### 2. 実装計画立案
仕様書を基に `.claude/plans/` に実装計画を作成します。

### 3. タスク細分化 & GitHub Issue 登録
実装計画を細分化し、並列実行可能な単位に分割します。
分割されたタスクは `.claude/tasks/backlog/` に配置し、**GitHub Issue に登録**します。

```bash
# タスクファイルから Issue を作成
./scripts/create-issue-from-task.sh TASK-XXX
# または: gh issue create --title "タイトル" --label "feature,status: backlog" --body "内容"
```

### 4. 並列実装
複数の Claude Code インスタンスが `backlog` からタスクを取得し、
`in-progress/[instance-name]/` で並列実装します。

**各フローで必須:**
- タスクファイルの移動
- GitHub Issue のステータス更新（`gh issue edit`）
- `.claude/dashboard.md` の更新

```bash
# タスク開始時
mv .claude/tasks/backlog/TASK-XXX.md .claude/tasks/in-progress/[instance-name]/
gh issue edit <number> --add-label "status: in-progress" --remove-label "status: backlog"
# dashboard.md を更新
```

### 5. レビュー
実装完了後、`.claude/tasks/review/` に移動し、
別の Claude Code インスタンスが自動レビューを実行します。

```bash
# レビュー依頼時
mv .claude/tasks/in-progress/[instance-name]/TASK-XXX.md .claude/tasks/review/
gh issue edit <number> --add-label "status: review" --remove-label "status: in-progress"
# dashboard.md を更新
```

### 6. 修正対応
レビュー指摘事項を自動で修正し、再レビューまで実施します。

### 7. 完了
すべてのレビューが承認されたタスクは `.claude/tasks/completed/` に移動します。

```bash
# 完了時
mv .claude/tasks/review/TASK-XXX.md .claude/tasks/completed/
gh issue close <number> --comment "実装完了"
# dashboard.md を更新
```

## GitHub Issue 統合ワークフロー

GitHub Issue をタスク管理の中心として活用できます。
**すべての GitHub 操作は GitHub CLI (`gh`) を使用します。**

### Issue ベースの実装フロー

```
[タスクファイル作成 or GitHub Issue作成] ← チーム全体に可視化
    ↓
[gh コマンドで Issue 登録/取得]
    ↓
[タスクファイルと Issue を同期]
    ↓
[.claude/tasks/backlog/に配置]
    ↓
[タスク開始: backlog → in-progress + Issue ステータス更新 + dashboard.md 更新]
    ↓
[実装 & コミット (Issue 参照)]
    ↓
[レビュー依頼: in-progress → review + Issue ステータス更新 + dashboard.md 更新]
    ↓
[完了: review → completed + Issue クローズ + dashboard.md 更新]
```

### 基本的な使い方

#### 1. GitHub CLI のセットアップ

```bash
# GitHub CLI をインストール
brew install gh  # macOS
# または
sudo apt install gh  # Linux

# 認証
gh auth login

# スクリプトに実行権限を付与
chmod +x scripts/*.sh
```

#### 2. タスク → Issue 登録

```bash
# タスクファイルから GitHub Issue を作成
./scripts/create-issue-from-task.sh TASK-001

# または直接 gh コマンドで作成
gh issue create --title "[Feature] タイトル" --label "feature,status: backlog" --body "内容"
```

#### 3. Issue → タスク生成

```bash
# 未着手の Issue 一覧を表示
gh issue list --label "status: backlog"

# Issue #123 をタスクファイルに変換
./scripts/sync-issue-to-task.sh 123

# 生成されたタスクファイル: .claude/tasks/backlog/TASK-123.md
```

#### 4. タスクを開始

```bash
# タスクを in-progress に移動
mv .claude/tasks/backlog/TASK-123.md .claude/tasks/in-progress/claude-1/

# Issue のステータスを更新
./scripts/update-issue-status.sh 123 in-progress
# または: gh issue edit 123 --add-label "status: in-progress" --remove-label "status: backlog"

# .claude/dashboard.md を更新（必須）
```

#### 5. 実装 & コミット

```bash
# 実装後、Issue を参照してコミット
git commit -m "[feat] ユーザーモデルを実装

Refs #123"
```

#### 6. PR作成 & Issueクローズ

```bash
# PR を作成（Issue を自動クローズ）
gh pr create --title "ユーザーモデルを実装" --body "Closes #123"

# .claude/dashboard.md を更新（必須）
```

詳細は `.claude/workflows/github-issue-integration.md` を参照してください。

## 使い方

### 新規プロジェクトの開始

1. このテンプレートをコピー
2. `docs/rules/project-setup.md` に従ってプロジェクト固有の設定を追加
3. 使用する言語のコーディング規約を `docs/rules/coding-standards/` から選択
4. `docs/rules/terminology.md` にプロジェクト固有の用語を追加

### 新機能の追加

1. `templates/feature-spec.md` をコピーして `docs/specs/features/` に配置
2. 機能仕様を記載
3. Claude Code に実装計画の作成を依頼
4. タスク細分化後、並列実装を開始

## 主要ドキュメント

### 開発ルール
- **機能仕様書の書き方**: `docs/specs/README.md`
- **コーディング規約**: `docs/rules/coding-standards/`
- **用語集**: `docs/rules/terminology.md`
- **テストポリシー**: `docs/rules/testing-policy.md`
- **セキュリティガイドライン**: `docs/rules/security.md`

### Claude Code ワークフロー
- **並列開発ガイド**: `.claude/workflows/parallel-dev.md`
- **レビューガイドライン**: `.claude/reviews/guidelines.md`
- **タスク細分化ルール**: `.claude/workflows/task-breakdown.md`
- **GitHub Issue 統合**: `.claude/workflows/github-issue-integration.md`
- **進捗ダッシュボード**: `.claude/dashboard.md`

### テンプレート
- **CI/CD設定**: `templates/ci/`
- **各種テンプレート**: `templates/`

## 注意事項

- 機能仕様書には具体的なコードは記載しません（実装との乖離を防ぐため）
- データフローは図や自然言語で表現します
- タスクは他のタスクへの依存を最小化し、並列実行可能な粒度に分割します
- レビューは自動化を前提としますが、最終的な判断は人間が行います

## 拡張機能

このテンプレートには以下の拡張機能が含まれています：

### 1. タスク依存関係管理
`.claude/tasks/dependencies.yaml` でタスク間の依存関係を定義できます。
並列実行時の順序制御に活用してください。

### 2. 進捗可視化
`.claude/dashboard.md` で全タスクの進捗状況を一覧表示します。
各 Claude インスタンスが実行時に自動更新します。

### 3. 共有コンテキスト
`.claude/context/` に全インスタンスで共有する情報を格納します。
API仕様や共通インターフェース定義など、統一的な理解が必要な情報を配置してください。

### 4. テストポリシー
`docs/rules/testing-policy.md` にテスト戦略とカバレッジ基準を定義します。
単体テスト、統合テスト、E2Eテストの方針を明確にしてください。

### 5. セキュリティガイドライン
`docs/rules/security.md` にセキュリティチェックリストを用意しています。
OWASP Top 10 などの観点から、実装時の注意点を記載してください。

### 6. CI/CD テンプレート
`templates/ci/` に各種CI/CDツールの設定例があります。
プロジェクトに応じてカスタマイズしてください。

## ライセンス

プロジェクトに応じて設定してください。
