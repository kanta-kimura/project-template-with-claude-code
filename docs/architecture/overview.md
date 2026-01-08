# アーキテクチャ概要

プロジェクトのアーキテクチャの概要を記載します。

## システム概要

[プロジェクトの簡単な説明を記載]

このドキュメントはプロジェクト開始時に更新してください。

## アーキテクチャ図

```
[ここにシステムの全体像を図で表現]

例:
┌─────────────┐
│   クライアント   │
│  (Web/Mobile)  │
└──────┬──────┘
       │ HTTPS
┌──────▼──────┐
│   API GW    │
│  (認証/認可)  │
└──────┬──────┘
       │
┌──────▼──────┐
│ Application │
│   Server    │
└──────┬──────┘
       │
┌──────▼──────┐
│  Database   │
└─────────────┘
```

## 技術スタック

### フロントエンド
- フレームワーク: [React / Vue / Angular など]
- 言語: [TypeScript]
- 状態管理: [Redux / Vuex / など]
- UI ライブラリ: [Material-UI / Ant Design / など]

### バックエンド
- フレームワーク: [Express / FastAPI / Spring Boot / など]
- 言語: [TypeScript / Python / Java / など]
- ORM: [TypeORM / SQLAlchemy / など]

### データベース
- RDBMS: [PostgreSQL / MySQL / など]
- NoSQL: [MongoDB / Redis / など]

### インフラ
- ホスティング: [AWS / GCP / Azure / など]
- コンテナ: [Docker / Kubernetes]
- CI/CD: [GitHub Actions / GitLab CI / など]

## アーキテクチャパターン

### レイヤードアーキテクチャ

```
┌──────────────────────┐
│  Presentation Layer  │  ← ルーティング、コントローラー
├──────────────────────┤
│   Application Layer  │  ← ビジネスロジック、サービス
├──────────────────────┤
│     Domain Layer     │  ← エンティティ、ドメインモデル
├──────────────────────┤
│ Infrastructure Layer │  ← データベース、外部API
└──────────────────────┘
```

### ディレクトリ構造

```
src/
├── controllers/      # リクエストハンドラ
├── services/         # ビジネスロジック
├── models/           # データモデル
├── repositories/     # データアクセス
├── middlewares/      # ミドルウェア
├── utils/            # ユーティリティ
└── config/           # 設定
```

## データフロー

### リクエストの流れ

```
Client
  ↓ HTTP Request
Middleware (認証)
  ↓
Controller (リクエスト受信)
  ↓
Service (ビジネスロジック)
  ↓
Repository (データアクセス)
  ↓
Database
  ↓
Repository (データ取得)
  ↓
Service (データ加工)
  ↓
Controller (レスポンス生成)
  ↓ HTTP Response
Client
```

## 主要コンポーネント

### 認証・認可

- JWT トークンベースの認証
- ロールベースのアクセス制御（RBAC）
- リフレッシュトークンによるトークン更新

### データベース設計

主要なテーブルとその関係を記載します。

```
users
  ├─ id (PK)
  ├─ email
  ├─ password_hash
  └─ created_at

sessions
  ├─ id (PK)
  ├─ user_id (FK → users.id)
  ├─ token
  └─ expires_at
```

### API 設計

詳細は `.claude/context/api-specs.md` を参照。

## スケーラビリティ

### 水平スケーリング

- ステートレスなアプリケーションサーバー
- ロードバランサーによる負荷分散
- セッション情報は Redis で共有

### キャッシング戦略

- Redis によるデータキャッシュ
- CDN による静的ファイルの配信
- ブラウザキャッシュの活用

## セキュリティ

### 認証

- パスワードは bcrypt でハッシュ化
- JWT トークンによる API 認証
- リフレッシュトークンのローテーション

### 通信

- すべての通信を HTTPS で暗号化
- CORS の適切な設定
- セキュリティヘッダーの設定

詳細は `docs/rules/security.md` を参照。

## モニタリング・ロギング

### ログ

- 構造化ログ（JSON 形式）
- ログレベル: ERROR, WARN, INFO, DEBUG
- 集約: [CloudWatch / Elasticsearch / など]

### メトリクス

- レスポンスタイム
- エラー率
- リクエスト数
- データベース接続数

### アラート

- エラー率が閾値を超えた場合
- レスポンスタイムが閾値を超えた場合
- サーバーダウン時

## デプロイ戦略

### ブルーグリーンデプロイ

1. 新バージョンを別環境にデプロイ（グリーン）
2. ヘルスチェック
3. トラフィックを新環境に切り替え
4. 問題があれば旧環境（ブルー）に即座にロールバック

### CI/CD パイプライン

```
コミット
  ↓
ビルド
  ↓
テスト
  ↓
セキュリティスキャン
  ↓
ステージング環境にデプロイ
  ↓
E2E テスト
  ↓
本番環境にデプロイ
```

## パフォーマンス目標

- ページロード時間: 3秒以内
- API レスポンスタイム: 100ms 以内
- 同時接続数: 1000ユーザー
- 可用性: 99.9%

## 制約事項

### 技術的制約

- [記載例] データベースは PostgreSQL 14 以上を使用
- [記載例] Node.js 18 以上が必要

### ビジネス的制約

- [記載例] 個人情報は日本国内のデータセンターに保存
- [記載例] GDPR / 個人情報保護法に準拠

## 今後の拡張性

### 短期的な拡張

- [記載例] ソーシャルログインの追加
- [記載例] モバイルアプリ対応

### 長期的な拡張

- [記載例] マイクロサービス化
- [記載例] GraphQL API の追加
- [記載例] リアルタイム通知機能

## 参考資料

- [The Twelve-Factor App](https://12factor.net/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Microsoft Azure アーキテクチャセンター](https://docs.microsoft.com/ja-jp/azure/architecture/)

---

## 更新履歴

| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2025-01-08 | 初版作成 | - |

**注意**: このドキュメントはプロジェクト開始時に具体的な内容で更新してください。
