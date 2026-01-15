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

複数の Claude Code インスタンスで同時に開発を進めることができます。
GitHub Issues を中心にタスクを管理し、各インスタンスが独立して作業します。

### 全体像

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Issues                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Issue #1 │ │ Issue #2 │ │ Issue #3 │ │ Issue #4 │       │
│  │ backlog  │ │ backlog  │ │ backlog  │ │ backlog  │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└─────────────────────────────────────────────────────────────┘
        │              │              │
        │ 取得         │ 取得         │ 取得
        ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  Claude #1  │ │  Claude #2  │ │  Claude #3  │
│  Issue #1   │ │  Issue #2   │ │  Issue #3   │
│ in-progress │ │ in-progress │ │ in-progress │
│             │ │             │ │             │
│ src/auth/   │ │ src/api/    │ │ src/ui/     │
│ branch:     │ │ branch:     │ │ branch:     │
│ issue/1-*   │ │ issue/2-*   │ │ issue/3-*   │
└─────────────┘ └─────────────┘ └─────────────┘
        │              │              │
        │ PR作成       │ PR作成       │ PR作成
        ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Pull Requests                     │
│         PR → Issue 自動リンク（Closes #1 等）               │
└─────────────────────────────────────────────────────────────┘
        │              │              │
        │ マージ       │ マージ       │ マージ
        ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                    main ブランチ                            │
│              .claude/context/ - 共有情報                    │
└─────────────────────────────────────────────────────────────┘
```

### ステータスラベルによる状態管理

GitHub Issues のラベルでタスクの状態を管理:

| ラベル | 状態 | 説明 |
|--------|------|------|
| `status: backlog` | 未着手 | 誰も作業していない |
| `status: in-progress` | 作業中 | いずれかのインスタンスが担当 |
| `status: review` | レビュー中 | PR 作成済み、レビュー待ち |

```bash
# 未着手の Issue 一覧
gh issue list --label "status: backlog"

# 作業中の Issue 一覧
gh issue list --label "status: in-progress"
```

### 並列開発の流れ

```bash
# ===== ターミナル1: Claude #1 =====
cd /path/to/project && claude

# 1. 未着手 Issue を確認
gh issue list --label "status: backlog"

# 2. Issue #1 を選択して開始
./scripts/task.sh start 1
# → ラベルが backlog → in-progress に変更される

# 3. ブランチ作成 & 実装
git checkout -b issue/1-auth-login
# ... 実装 ...

# 4. コミット（Issue 参照）
git commit -m "[feat] ログイン機能を実装 Refs #1"

# 5. PR 作成（Issue 自動クローズ設定）
git push origin issue/1-auth-login
gh pr create --title "ログイン機能" --body "Closes #1"

# 6. レビュー依頼
./scripts/task.sh review 1
# → ラベルが in-progress → review に変更される
```

```bash
# ===== ターミナル2: Claude #2 =====（同時進行）
cd /path/to/project && claude

# 別の Issue #2 を選択して同様に作業
./scripts/task.sh start 2
git checkout -b issue/2-user-api
# ... 実装 ...
```

### タスク選択のルール

| 優先度 | ルール | 理由 |
|--------|--------|------|
| 高 | `status: backlog` の Issue を選ぶ | 重複作業を防止 |
| 高 | 異なるファイルを編集する Issue | Git 競合を回避 |
| 中 | 依存関係がない Issue | 待ち時間を削減 |
| 低 | 同じモジュール内の Issue | 競合リスクあり |

**良い例:**
```
Claude #1: Issue #1 - src/auth/login.ts（認証）
Claude #2: Issue #2 - src/api/users.ts（API）
Claude #3: Issue #3 - src/components/Header.tsx（UI）
```

**避けるべき例:**
```
Claude #1: Issue #1 - src/utils/helpers.ts の funcA
Claude #2: Issue #2 - src/utils/helpers.ts の funcB
→ 同じファイル = 競合リスク大
```

### Issue と PR の連携

コミットや PR で Issue を参照すると自動でリンクされる:

```bash
# コミットで参照（Issue は開いたまま）
git commit -m "[feat] 機能追加 Refs #1"

# PR で自動クローズ
gh pr create --body "Closes #1"
# → PR マージ時に Issue #1 が自動クローズ
```

### 共有コンテキスト

`.claude/context/` に全インスタンスが参照する情報を配置:

```
.claude/context/
├── api-specs.md          # API エンドポイント定義
├── interfaces.md         # 共通型・インターフェース
└── workflow-quick-ref.md # ワークフロー参照
```

新しい API や型を追加したら、ここに記録して他のインスタンスと共有。

### 競合が発生した場合

1. `gh issue list --label "status: in-progress"` で作業中タスクを確認
2. 競合するファイルを編集している Issue があれば、完了を待つ
3. 先にマージされた変更を取り込んでから続行

```bash
git fetch origin main
git rebase origin/main
# 競合解決後
git push origin issue/1-auth-login --force-with-lease
```

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
