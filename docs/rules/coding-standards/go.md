# Go コーディング規約

## 概要

Go プロジェクトのコーディング規約です。
基本的に Effective Go と Go Code Review Comments に従います。

## 基本設定

### Go バージョン
Go 1.21 以上を使用します。

### フォーマッタ
gofmt を使用します。

```bash
gofmt -w .
```

### リンター
golangci-lint を使用します。

```bash
golangci-lint run
```

## 命名規則

### 変数・関数
camelCase を使用します。

```go
userName := "Alice"
isActive := true

func getUserByID(userID string) (*User, error) {
    // ...
}
```

### 公開・非公開
先頭文字の大文字/小文字で決まります。

```go
// 公開（他のパッケージからアクセス可能）
type User struct {
    Name string
}

func GetUser(id string) (*User, error) {
    // ...
}

// 非公開（パッケージ内のみ）
type userCache struct {
    data map[string]*User
}

func validateEmail(email string) bool {
    // ...
}
```

### 定数
UPPER_SNAKE_CASE または camelCase を使用します。

```go
const (
    MaxRetryCount = 3
    APIBaseURL = "https://api.example.com"
)
```

### インターフェース
動詞 + er の形式を推奨します。

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type UserRepository interface {
    FindByID(id string) (*User, error)
    Save(user *User) error
}
```

### ファイル名
snake_case を使用します。

```
user_service.go
auth_middleware.go
```

## エラーハンドリング

### エラーチェックは即座に
```go
// ✅ エラーチェック
user, err := getUserByID(userID)
if err != nil {
    return nil, fmt.Errorf("failed to get user: %w", err)
}

// ❌ エラーを無視
user, _ := getUserByID(userID)
```

### エラーラップ
```go
// ✅ エラーをラップ
if err := db.Save(user); err != nil {
    return fmt.Errorf("failed to save user %s: %w", user.ID, err)
}

// エラーのアンラップ
if errors.Is(err, ErrNotFound) {
    // NotFound エラーの処理
}

if var validationErr *ValidationError; errors.As(err, &validationErr) {
    // ValidationError の処理
}
```

### カスタムエラー
```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error: %s - %s", e.Field, e.Message)
}

// 使用例
if email == "" {
    return &ValidationError{
        Field:   "email",
        Message: "email is required",
    }
}
```

### センチネルエラー
```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)

func GetUser(id string) (*User, error) {
    user, err := db.FindByID(id)
    if err != nil {
        return nil, ErrNotFound
    }
    return user, nil
}
```

## 構造体

### フィールドの順序
```go
type User struct {
    // グループ化して読みやすく
    ID    string
    Name  string
    Email string

    CreatedAt time.Time
    UpdatedAt time.Time

    // 埋め込み構造体は最後
    sync.Mutex
}
```

### コンストラクタ
```go
func NewUser(name, email string) *User {
    return &User{
        ID:        generateID(),
        Name:      name,
        Email:     email,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }
}
```

### メソッド
```go
// ✅ ポインタレシーバ（状態を変更する場合）
func (u *User) UpdateName(name string) {
    u.Name = name
    u.UpdatedAt = time.Now()
}

// ✅ 値レシーバ（状態を変更しない場合）
func (u User) IsActive() bool {
    return u.DeletedAt == nil
}
```

## 並行処理

### goroutine
```go
// ✅ goroutine の起動
go func() {
    if err := processUser(user); err != nil {
        log.Printf("failed to process user: %v", err)
    }
}()

// ✅ WaitGroup で待機
var wg sync.WaitGroup
for _, user := range users {
    wg.Add(1)
    go func(u *User) {
        defer wg.Done()
        processUser(u)
    }(user)
}
wg.Wait()
```

### チャネル
```go
// ✅ バッファ付きチャネル
results := make(chan *User, 10)

// ✅ チャネルのクローズ
go func() {
    defer close(results)
    for _, user := range users {
        results <- processUser(user)
    }
}()

// ✅ select で複数チャネル処理
select {
case user := <-results:
    fmt.Println(user.Name)
case <-ctx.Done():
    return ctx.Err()
}
```

### Context
```go
func FetchUser(ctx context.Context, userID string) (*User, error) {
    // タイムアウト付きコンテキスト
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    // コンテキストのキャンセルチェック
    select {
    case <-ctx.Done():
        return nil, ctx.Err()
    default:
    }

    // ...
}
```

### Mutex
```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]*User
}

func (c *Cache) Get(key string) (*User, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    user, ok := c.items[key]
    return user, ok
}

func (c *Cache) Set(key string, user *User) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = user
}
```

## インターフェース

### 小さく保つ
```go
// ✅ 小さなインターフェース
type Reader interface {
    Read(p []byte) (n int, err error)
}

// ✅ インターフェース合成
type ReadWriter interface {
    Reader
    Writer
}
```

### 受け入れ側で定義
```go
// ❌ 実装側でインターフェース定義
package user
type UserRepository interface { /* ... */ }
type UserService struct {
    repo UserRepository
}

// ✅ 使用側でインターフェース定義
package user
type Service struct {
    repo repository
}

type repository interface {
    FindByID(id string) (*User, error)
}
```

## テスト

### テストファイル名
```
user_service.go       → user_service_test.go
auth_middleware.go    → auth_middleware_test.go
```

### テーブル駆動テスト
```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        want    bool
    }{
        {"valid email", "user@example.com", true},
        {"missing @", "userexample.com", false},
        {"missing domain", "user@", false},
        {"empty", "", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := validateEmail(tt.email)
            if got != tt.want {
                t.Errorf("validateEmail(%q) = %v, want %v", tt.email, got, tt.want)
            }
        })
    }
}
```

### サブテスト
```go
func TestUserService(t *testing.T) {
    t.Run("FindByID", func(t *testing.T) {
        t.Run("existing user", func(t *testing.T) {
            // ...
        })

        t.Run("not found", func(t *testing.T) {
            // ...
        })
    })
}
```

### モック
```go
type mockUserRepository struct {
    users map[string]*User
}

func (m *mockUserRepository) FindByID(id string) (*User, error) {
    user, ok := m.users[id]
    if !ok {
        return nil, ErrNotFound
    }
    return user, nil
}

func TestUserService_GetUser(t *testing.T) {
    repo := &mockUserRepository{
        users: map[string]*User{
            "user-1": {ID: "user-1", Name: "Alice"},
        },
    }
    service := NewUserService(repo)

    user, err := service.GetUser("user-1")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Alice" {
        t.Errorf("got %v, want Alice", user.Name)
    }
}
```

## パッケージ

### パッケージ名
短く、明確な名前を使用します。

```go
package user      // ✅ 短い
package userdata  // ❌ 冗長
```

### パッケージコメント
```go
// Package user provides user management functionality.
package user
```

## コメント

### パッケージレベルのドキュメント
```go
// Package validator provides validation utilities for user input.
package validator
```

### 公開APIのドキュメント
```go
// GetUser retrieves a user by ID from the database.
// It returns ErrNotFound if the user does not exist.
func GetUser(id string) (*User, error) {
    // ...
}
```

## その他のベストプラクティス

### defer の活用
```go
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()

    // ファイル処理
    return nil
}
```

### 早期リターン
```go
// ✅ 早期リターン
func GetUser(id string) (*User, error) {
    if id == "" {
        return nil, errors.New("id is required")
    }

    user, err := db.FindByID(id)
    if err != nil {
        return nil, err
    }

    return user, nil
}

// ❌ ネストが深い
func GetUser(id string) (*User, error) {
    if id != "" {
        user, err := db.FindByID(id)
        if err == nil {
            return user, nil
        } else {
            return nil, err
        }
    } else {
        return nil, errors.New("id is required")
    }
}
```

### 空のインターフェース
```go
// ❌ interface{} の多用
func Process(data interface{}) error {
    // ...
}

// ✅ 具体的な型またはジェネリクス (Go 1.18+)
func Process[T any](data T) error {
    // ...
}
```

## チェックリスト

- [ ] gofmt でフォーマット
- [ ] golangci-lint でリント
- [ ] すべてのエラーをチェック
- [ ] 公開APIにコメントを記載
- [ ] テストを作成
- [ ] goroutine のリークがない
- [ ] Context を適切に使用
