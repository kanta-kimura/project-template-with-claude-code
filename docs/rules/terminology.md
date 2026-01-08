# 用語集・命名規則

プロジェクトで使用する用語とそれに対応する変数名の定義です。
一貫性のある命名を保つため、このドキュメントを参照してください。

## 基本原則

1. **一貫性**: 同じ概念には同じ用語を使用
2. **明確性**: 略語よりも完全な単語を優先
3. **言語固有**: コードは英語、ドキュメントは日本語

## ドメイン用語

### ユーザー関連

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| ユーザー | User | `user`, `currentUser` | システムを利用する人 |
| ユーザーID | User ID | `userId`, `user_id` | ユーザーの一意識別子 |
| ユーザー名 | Username | `username`, `userName` | ログイン時に使用する名前 |
| 表示名 | Display Name | `displayName`, `display_name` | UI に表示される名前 |
| メールアドレス | Email Address | `email`, `emailAddress` | ユーザーのメールアドレス |
| パスワード | Password | `password`, `hashedPassword` | 認証用パスワード |
| プロフィール | Profile | `profile`, `userProfile` | ユーザーの詳細情報 |
| 権限 | Permission | `permission`, `permissions` | アクセス権限 |
| ロール/役割 | Role | `role`, `userRole` | ユーザーの役割 |
| セッション | Session | `session`, `userSession` | ログインセッション |
| トークン | Token | `token`, `authToken` | 認証トークン |

### 認証・認可

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| ログイン | Login / Sign In | `login`, `signIn` | システムへの入場 |
| ログアウト | Logout / Sign Out | `logout`, `signOut` | システムからの退出 |
| サインアップ/登録 | Sign Up / Register | `signUp`, `register` | 新規ユーザー登録 |
| 認証 | Authentication | `auth`, `authenticate` | 本人確認 |
| 認可 | Authorization | `authorize`, `authz` | アクセス許可 |
| アクセストークン | Access Token | `accessToken`, `access_token` | API アクセス用トークン |
| リフレッシュトークン | Refresh Token | `refreshToken`, `refresh_token` | トークン更新用 |

### データ管理

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| 作成 | Create | `create`, `createUser` | 新規作成 |
| 読み取り/取得 | Read / Get / Fetch | `get`, `fetch`, `read` | データ取得 |
| 更新 | Update | `update`, `updateUser` | データ更新 |
| 削除 | Delete | `delete`, `deleteUser` | データ削除 |
| 検索 | Search / Find | `search`, `find` | データ検索 |
| フィルタ | Filter | `filter`, `filterBy` | 条件抽出 |
| ソート | Sort | `sort`, `sortBy` | 並べ替え |
| ページネーション | Pagination | `pagination`, `page` | ページ分割 |
| 一覧 | List | `list`, `userList` | 複数データの集合 |

### ステータス・状態

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| 有効 | Active / Enabled | `isActive`, `is_active` | 有効状態 |
| 無効 | Inactive / Disabled | `isDisabled`, `disabled` | 無効状態 |
| 削除済み | Deleted | `isDeleted`, `deletedAt` | 削除フラグ |
| 下書き | Draft | `isDraft`, `status: 'draft'` | 下書き状態 |
| 公開済み | Published | `isPublished`, `publishedAt` | 公開状態 |
| 保留中 | Pending | `isPending`, `status: 'pending'` | 保留状態 |
| 承認済み | Approved | `isApproved`, `approvedAt` | 承認済み |
| 却下 | Rejected | `isRejected`, `rejectedAt` | 却下済み |

### 時刻関連

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| 作成日時 | Created At | `createdAt`, `created_at` | 作成された日時 |
| 更新日時 | Updated At | `updatedAt`, `updated_at` | 最終更新日時 |
| 削除日時 | Deleted At | `deletedAt`, `deleted_at` | 削除された日時 |
| 公開日時 | Published At | `publishedAt`, `published_at` | 公開された日時 |
| 有効期限 | Expires At / Expiry Date | `expiresAt`, `expiry_date` | 有効期限 |
| タイムスタンプ | Timestamp | `timestamp`, `ts` | Unix時刻など |

## 技術用語

### API関連

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| リクエスト | Request | `request`, `req` | HTTP リクエスト |
| レスポンス | Response | `response`, `res` | HTTP レスポンス |
| エンドポイント | Endpoint | `endpoint`, `apiEndpoint` | API のURL |
| パラメータ | Parameter | `param`, `params` | クエリパラメータ |
| クエリ | Query | `query`, `searchQuery` | 検索条件 |
| ボディ | Body | `body`, `requestBody` | リクエスト本文 |
| ヘッダー | Header | `header`, `headers` | HTTP ヘッダー |
| ステータスコード | Status Code | `statusCode`, `status_code` | HTTP ステータス |

### データベース関連

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| テーブル | Table | `table`, `userTable` | データベーステーブル |
| カラム/列 | Column | `column`, `columnName` | テーブルの列 |
| 行/レコード | Row / Record | `row`, `record` | データ行 |
| 主キー | Primary Key | `id`, `primaryKey` | 主キー |
| 外部キー | Foreign Key | `userId`, `foreignKey` | 外部キー |
| インデックス | Index | `index`, `indexName` | データベースインデックス |
| クエリ | Query | `query`, `sqlQuery` | SQL クエリ |
| トランザクション | Transaction | `transaction`, `tx` | DB トランザクション |

### エラー関連

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| エラー | Error | `error`, `err` | エラー |
| 例外 | Exception | `exception`, `ex` | 例外 |
| エラーメッセージ | Error Message | `errorMessage`, `message` | エラーの説明 |
| エラーコード | Error Code | `errorCode`, `code` | エラー識別コード |
| スタックトレース | Stack Trace | `stackTrace`, `stack` | エラーの追跡情報 |

## 命名パターン

### Boolean 型

**パターン**: `is/has/can + 形容詞/名詞`

```typescript
// ✅ 良い例
isActive
isDeleted
isValid
hasPermission
canEdit
shouldRetry

// ❌ 悪い例
active (型が不明確)
deleted
valid
```

### 配列・リスト

**パターン**: 複数形

```typescript
// ✅ 良い例
users
items
results
userIds

// ❌ 悪い例
userList (冗長)
userArray
```

### 関数・メソッド

**パターン**: 動詞 + 名詞

```typescript
// ✅ 取得系
getUser
fetchUsers
findById
searchByName

// ✅ 変更系
createUser
updateUser
deleteUser
saveUser

// ✅ 判定系
validateEmail
checkPermission
isValidUser

// ✅ 変換系
convertToJson
parseDate
formatCurrency
```

### 定数

**パターン**: UPPER_SNAKE_CASE

```typescript
// ✅ 良い例
const MAX_RETRY_COUNT = 3
const API_BASE_URL = "https://api.example.com"
const DEFAULT_PAGE_SIZE = 20

// ❌ 悪い例
const maxRetryCount = 3
const ApiBaseUrl = "https://api.example.com"
```

### イベントハンドラ

**パターン**: `on/handle + イベント名`

```typescript
// ✅ 良い例
onClick
onSubmit
handleUserClick
handleFormSubmit

// ❌ 悪い例
click
submit
userClick
```

## 略語ルール

### 使用可能な略語

一般的に認知されている略語のみ使用します。

| 完全形 | 略語 | 使用例 |
|--------|------|--------|
| identification | id | `userId`, `orderId` |
| information | info | `userInfo` |
| configuration | config | `appConfig` |
| parameter | param | `queryParams` |
| error | err | `handleErr` |
| request | req | `httpReq` |
| response | res | `httpRes` |
| number | num | `pageNum` |
| maximum | max | `maxLength` |
| minimum | min | `minValue` |

### 避けるべき略語

```typescript
// ❌ 避ける
usr  → user
msg  → message
btn  → button
txt  → text
tmp  → temporary
```

## 言語別の特性

### TypeScript/JavaScript
- camelCase: 変数、関数
- PascalCase: クラス、型、インターフェース
- UPPER_SNAKE_CASE: 定数

### Python
- snake_case: 変数、関数
- PascalCase: クラス
- UPPER_SNAKE_CASE: 定数

### Go
- camelCase: 変数、関数
- PascalCase: 公開API
- UPPER_SNAKE_CASE: 定数

### Rust
- snake_case: 変数、関数
- PascalCase: 構造体、列挙型、トレイト
- UPPER_SNAKE_CASE: 定数

### Java
- camelCase: 変数、メソッド
- PascalCase: クラス、インターフェース
- UPPER_SNAKE_CASE: 定数

## プロジェクト固有の用語

以下のセクションに、プロジェクト固有の用語を追加してください。

### ビジネス用語

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| - | - | - | - |

### 技術用語

| 日本語 | 英語 | 変数名例 | 説明 |
|--------|------|----------|------|
| - | - | - | - |

## 更新履歴

| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2025-01-08 | 初版作成 | - |
