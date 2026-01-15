# プロジェクトテンプレート

Claude Code を活用した開発のためのプロジェクトテンプレートです。

## クイックスタート

```bash
# タスク一覧
./scripts/task.sh list

# タスク作成
./scripts/task.sh create "機能を実装"

# タスク開始
./scripts/task.sh start <id>

# レビュー依頼
./scripts/task.sh review <id>

# 完了
./scripts/task.sh done <id>
```

## タスク管理モード

`.claude/config.yaml` で切り替え：

| モード | 用途 | タスク管理場所 |
|--------|------|----------------|
| `github` | GitHub 利用時（推奨） | GitHub Issues |
| `local` | Bitbucket 等 | `.claude/tasks/TASK-XXX.md` |

## ディレクトリ構成

```
/
├── .claude/
│   ├── config.yaml           # プロジェクト設定
│   ├── tasks/                # ローカルモード用タスクファイル
│   ├── context/              # 共有情報
│   │   ├── api-specs.md
│   │   ├── interfaces.md
│   │   └── workflow-quick-ref.md
│   ├── workflows/            # ワークフロー定義
│   │   ├── task-workflow.md
│   │   ├── task-breakdown.md
│   │   └── review-process.md
│   ├── plans/                # 実装計画書
│   ├── reviews/              # レビュー記録
│   └── dashboard.md          # 進捗ダッシュボード
│
├── docs/
│   ├── specs/                # 機能仕様書
│   ├── rules/                # プロジェクトルール
│   │   ├── coding-standards/ # コーディング規約
│   │   ├── terminology.md    # 用語集
│   │   ├── git-workflow.md   # Git運用
│   │   ├── testing-policy.md # テスト戦略
│   │   └── security.md       # セキュリティ
│   ├── architecture/         # アーキテクチャ
│   └── adr/                  # ADR
│
├── scripts/
│   ├── task.sh               # タスク管理スクリプト
│   └── README.md
│
└── templates/                # テンプレート
    ├── task.md
    ├── feature-spec.md
    ├── implementation-plan.md
    ├── review.md
    ├── adr.md
    └── ci/
```

## 開発フロー

### 1. 機能仕様作成

`docs/specs/features/` に機能仕様を作成

### 2. 実装計画立案

`.claude/plans/` に実装計画を作成

### 3. タスク作成

```bash
./scripts/task.sh create "タスク名"
```

### 4. 実装

```bash
./scripts/task.sh start <id>
# 実装...
git commit -m "[feat] 機能実装 Refs #<id>"
```

### 5. レビュー & 完了

```bash
./scripts/task.sh review <id>
# レビュー承認後
./scripts/task.sh done <id>
```

## 並列開発

複数の Claude Code インスタンスで並列開発が可能です。

- 異なるファイルを編集するタスクを選択
- 依存関係がないタスクを優先
- 詳細: `.claude/workflows/task-workflow.md`

## 主要ドキュメント

| ドキュメント | 場所 |
|------------|------|
| タスク管理 | `scripts/README.md` |
| ワークフロー | `.claude/workflows/task-workflow.md` |
| コーディング規約 | `docs/rules/coding-standards/` |
| テストポリシー | `docs/rules/testing-policy.md` |
| セキュリティ | `docs/rules/security.md` |

## セットアップ

### GitHub モード（推奨）

```bash
brew install gh
gh auth login
chmod +x scripts/task.sh
```

### ローカルモード

```bash
chmod +x scripts/task.sh
# .claude/config.yaml の mode を local に変更
```
