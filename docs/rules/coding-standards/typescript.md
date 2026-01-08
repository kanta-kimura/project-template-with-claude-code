# TypeScript コーディング規約

## 概要

TypeScript プロジェクトのコーディング規約です。

## 基本設定

### tsconfig.json
```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### フォーマッタ
Prettier を使用します。

## 型定義

### any を避ける
```typescript
// ❌ 避ける
function process(data: any) {
  return data.value
}

// ✅ 推奨
function process(data: { value: string }) {
  return data.value
}

// ✅ またはジェネリクス
function process<T>(data: T): T {
  return data
}
```

### unknown を活用
```typescript
// ✅ 型が不明な場合は unknown
function parseJson(json: string): unknown {
  return JSON.parse(json)
}

const data = parseJson('{"name": "Alice"}')
// 使用前に型チェック
if (typeof data === 'object' && data !== null && 'name' in data) {
  console.log(data.name)
}
```

### 明示的な型定義
```typescript
// ❌ 暗黙的な any
export function getUser(id) {
  return db.users.find(id)
}

// ✅ 明示的な型
export function getUser(id: string): Promise<User | null> {
  return db.users.find(id)
}
```

## 命名規則

### 変数・関数
camelCase を使用します。

```typescript
const userName = 'Alice'
const isActive = true
function getUserById(id: string) { }
```

### クラス・型・インターフェース
PascalCase を使用します。

```typescript
class UserService { }
interface User { }
type UserRole = 'admin' | 'user'
```

### 定数
UPPER_SNAKE_CASE を使用します。

```typescript
const MAX_RETRY_COUNT = 3
const API_BASE_URL = 'https://api.example.com'
```

### ファイル名
kebab-case を使用します。

```
user-service.ts
auth-middleware.ts
```

### プライベートフィールド
`#` または `private` を使用します。

```typescript
class User {
  #password: string  // ✅ プライベートフィールド

  private hashPassword() {  // ✅ プライベートメソッド
    // ...
  }
}
```

## 関数

### 関数宣言 vs アロー関数
```typescript
// ✅ トップレベル: 関数宣言
function createUser(name: string): User {
  return { name }
}

// ✅ コールバック: アロー関数
users.map(user => user.name)

// ✅ クラスメソッド: 通常のメソッド
class UserService {
  getUser(id: string) {
    return this.users.find(u => u.id === id)
  }
}
```

### 引数の数
引数が3つ以上の場合はオブジェクトにまとめます。

```typescript
// ❌ 引数が多すぎる
function createUser(name: string, email: string, age: number, role: string) { }

// ✅ オブジェクトにまとめる
interface CreateUserParams {
  name: string
  email: string
  age: number
  role: string
}

function createUser(params: CreateUserParams) { }
```

### 戻り値の型
明示的に型を指定します。

```typescript
// ❌ 暗黙的
function getUser(id: string) {
  return db.users.find(id)
}

// ✅ 明示的
function getUser(id: string): Promise<User | null> {
  return db.users.find(id)
}
```

## 非同期処理

### async/await を優先
```typescript
// ❌ Promise chain
function fetchUser(id: string) {
  return fetch(`/api/users/${id}`)
    .then(res => res.json())
    .then(data => data.user)
}

// ✅ async/await
async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  const data = await res.json()
  return data.user
}
```

### エラーハンドリング
```typescript
async function fetchUser(id: string): Promise<User> {
  try {
    const res = await fetch(`/api/users/${id}`)
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`)
    }
    const data = await res.json()
    return data.user
  } catch (error) {
    logger.error('Failed to fetch user', { id, error })
    throw error
  }
}
```

## Null 安全

### Optional chaining
```typescript
// ❌ 冗長なチェック
const name = user && user.profile && user.profile.name

// ✅ Optional chaining
const name = user?.profile?.name
```

### Nullish coalescing
```typescript
// ❌ || は 0 や '' も false扱い
const count = user.loginCount || 0

// ✅ ?? は null/undefined のみ
const count = user.loginCount ?? 0
```

## 配列・オブジェクト操作

### スプレッド演算子
```typescript
// ✅ 配列のコピー
const newItems = [...items]

// ✅ オブジェクトのマージ
const updatedUser = { ...user, name: 'Alice' }
```

### 分割代入
```typescript
// ✅ 配列
const [first, second] = items

// ✅ オブジェクト
const { name, email } = user

// ✅ 関数の引数
function createUser({ name, email }: { name: string; email: string }) {
  // ...
}
```

### map, filter, reduce を活用
```typescript
// ✅ map
const names = users.map(u => u.name)

// ✅ filter
const activeUsers = users.filter(u => u.isActive)

// ✅ reduce
const total = items.reduce((sum, item) => sum + item.price, 0)
```

## クラス

### 小さく保つ
```typescript
// ✅ 単一責任
class UserRepository {
  async findById(id: string): Promise<User | null> {
    return db.users.findOne({ id })
  }

  async save(user: User): Promise<void> {
    await db.users.save(user)
  }
}
```

### コンストラクタの簡略化
```typescript
// ✅ パラメータプロパティ
class User {
  constructor(
    private id: string,
    private name: string,
    private email: string
  ) {}
}
```

## エラーハンドリング

### カスタムエラー
```typescript
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

// 使用例
if (!email.includes('@')) {
  throw new ValidationError('Invalid email format', 'email')
}
```

### エラーの型
```typescript
// ✅ エラーの型チェック
try {
  await someOperation()
} catch (error) {
  if (error instanceof ValidationError) {
    console.log(`Validation failed: ${error.field}`)
  } else if (error instanceof Error) {
    console.log(error.message)
  } else {
    console.log('Unknown error')
  }
}
```

## インポート

### 順序
```typescript
// 1. 外部ライブラリ
import express from 'express'
import { z } from 'zod'

// 2. 内部モジュール（絶対パス）
import { UserService } from '@/services/user-service'
import { logger } from '@/utils/logger'

// 3. 相対パス
import { helper } from './helper'
```

### 名前付きインポート優先
```typescript
// ❌ デフォルトインポート
import utils from './utils'

// ✅ 名前付きインポート
import { formatDate, parseDate } from './utils'
```

## 型ユーティリティ

### Partial, Required, Pick, Omit を活用
```typescript
interface User {
  id: string
  name: string
  email: string
  age: number
}

// 一部のフィールドのみ更新
type UserUpdateInput = Partial<Pick<User, 'name' | 'email'>>

// 特定のフィールドを除外
type UserPublic = Omit<User, 'email'>
```

## コメント

### JSDoc
公開APIにはJSDocを追加します。

```typescript
/**
 * ユーザーIDからユーザー情報を取得します
 *
 * @param id - ユーザーID
 * @returns ユーザー情報、見つからない場合は null
 * @throws {NotFoundError} ユーザーが削除済みの場合
 */
async function getUser(id: string): Promise<User | null> {
  // ...
}
```

## テスト

### テストファイル名
```
user-service.ts       → user-service.test.ts
auth-middleware.ts    → auth-middleware.test.ts
```

### テスト構造
```typescript
describe('UserService', () => {
  describe('findById', () => {
    test('存在するユーザーを取得できる', async () => {
      const user = await userService.findById('user-123')
      expect(user).toBeDefined()
      expect(user?.id).toBe('user-123')
    })

    test('存在しないユーザーの場合はnullを返す', async () => {
      const user = await userService.findById('not-found')
      expect(user).toBeNull()
    })
  })
})
```

## チェックリスト

- [ ] `strict: true` が有効
- [ ] `any` を使用していない
- [ ] すべての関数に戻り値の型を指定
- [ ] エラーハンドリングが適切
- [ ] Optional chaining, Nullish coalescing を活用
- [ ] 公開APIにJSDocを記載
- [ ] テストを作成
