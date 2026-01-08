# 共通インターフェース定義

全インスタンスで共有する型定義・インターフェースを記載します。

## 概要

このドキュメントはプロジェクト全体で使用する共通の型定義やインターフェースを定義します。
実装前にここを確認し、既存の定義を活用してください。

---

## 基本型

### ユーザー関連

#### User
```typescript
interface User {
  id: string
  email: string
  name: string
  createdAt: Date
  updatedAt: Date
}
```

#### UserCreateInput
```typescript
interface UserCreateInput {
  email: string
  password: string
  name: string
}
```

#### UserUpdateInput
```typescript
interface UserUpdateInput {
  email?: string
  name?: string
  password?: string
}
```

### 認証関連

#### AuthToken
```typescript
interface AuthToken {
  accessToken: string
  refreshToken?: string
  expiresIn: number
}
```

#### AuthPayload
```typescript
interface AuthPayload {
  user: User
  token: AuthToken
}
```

---

## API レスポンス型

### 成功レスポンス
```typescript
interface ApiSuccessResponse<T> {
  success: true
  data: T
}
```

### エラーレスポンス
```typescript
interface ApiErrorResponse {
  success: false
  error: {
    code: string
    message: string
    details?: Record<string, any>
  }
}
```

### 汎用レスポンス
```typescript
type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse
```

### ページネーション付きレスポンス
```typescript
interface PaginatedResponse<T> {
  items: T[]
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}
```

---

## データベース関連

### BaseEntity
```typescript
interface BaseEntity {
  id: string
  createdAt: Date
  updatedAt: Date
  deletedAt?: Date | null
}
```

### Repository インターフェース
```typescript
interface Repository<T> {
  findById(id: string): Promise<T | null>
  findAll(): Promise<T[]>
  create(data: Partial<T>): Promise<T>
  update(id: string, data: Partial<T>): Promise<T>
  delete(id: string): Promise<void>
}
```

---

## エラー型

### AppError
```typescript
class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public details?: Record<string, any>
  ) {
    super(message)
    this.name = 'AppError'
  }
}
```

### 定義済みエラー
```typescript
class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, any>) {
    super('VALIDATION_ERROR', message, 400, details)
  }
}

class AuthenticationError extends AppError {
  constructor(message: string = '認証が必要です') {
    super('AUTHENTICATION_ERROR', message, 401)
  }
}

class AuthorizationError extends AppError {
  constructor(message: string = '権限がありません') {
    super('AUTHORIZATION_ERROR', message, 403)
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super('NOT_FOUND', `${resource}が見つかりません`, 404)
  }
}
```

---

## ユーティリティ型

### Nullable
```typescript
type Nullable<T> = T | null
```

### Optional
```typescript
type Optional<T> = T | undefined
```

### AsyncFunction
```typescript
type AsyncFunction<T = void> = () => Promise<T>
```

### ID型
```typescript
type ID = string

// 特定のリソースID
type UserID = ID
type PostID = ID
```

---

## 設定・環境変数

### Config
```typescript
interface Config {
  app: {
    port: number
    env: 'development' | 'production' | 'test'
  }
  database: {
    host: string
    port: number
    name: string
    user: string
    password: string
  }
  auth: {
    jwtSecret: string
    jwtExpiresIn: string
  }
}
```

---

## 命名規則

### インターフェース
- PascalCase を使用
- 名詞で命名
- Input/Output の区別: `UserCreateInput`, `UserResponse`

### 型エイリアス
- PascalCase を使用
- 目的が明確な名前: `ApiResponse`, `ErrorCode`

### ジェネリクス
- 単一文字: `T`, `U`, `V`
- 意味のある名前: `TData`, `TResponse`

---

## 言語別の対応

### Python
```python
from typing import TypedDict, Optional
from datetime import datetime

class User(TypedDict):
    id: str
    email: str
    name: str
    created_at: datetime
    updated_at: datetime
```

### Go
```go
type User struct {
    ID        string    `json:"id"`
    Email     string    `json:"email"`
    Name      string    `json:"name"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"updatedAt"`
}
```

### Java
```java
public class User {
    private String id;
    private String email;
    private String name;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

---

## 更新履歴

このセクションにインターフェース定義の変更履歴を記録してください。

| 日付 | 変更内容 | 影響範囲 | 担当 |
|------|---------|---------|------|
| 2025-01-08 | 初版作成 | - | - |

---

## 実装時の注意事項

1. **既存の型を確認**: 新しい型を定義する前に、ここに定義されているか確認
2. **共通化**: 複数の場所で使う型はここに追加
3. **命名規則**: 上記の命名規則に従う
4. **ドキュメント更新**: 新しい型を追加したら必ず記録
5. **breaking change**: 既存の型を変更する場合は影響範囲を確認
