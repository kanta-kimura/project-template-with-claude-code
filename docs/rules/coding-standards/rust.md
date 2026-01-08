# Rust コーディング規約

## 概要

Rust プロジェクトのコーディング規約です。
基本的に The Rust Programming Language と Rust API Guidelines に従います。

## 基本設定

### Rust バージョン
最新の stable を使用します。

### フォーマッタ
rustfmt を使用します。

```bash
cargo fmt
```

### リンター
clippy を使用します。

```bash
cargo clippy -- -D warnings
```

## 命名規則

### 変数・関数
snake_case を使用します。

```rust
let user_name = "Alice";
let is_active = true;

fn get_user_by_id(user_id: &str) -> Option<User> {
    // ...
}
```

### 構造体・列挙型・トレイト
PascalCase を使用します。

```rust
struct User {
    id: String,
    name: String,
}

enum UserRole {
    Admin,
    User,
}

trait UserRepository {
    fn find_by_id(&self, id: &str) -> Option<User>;
}
```

### 定数・静的変数
UPPER_SNAKE_CASE を使用します。

```rust
const MAX_RETRY_COUNT: u32 = 3;
static API_BASE_URL: &str = "https://api.example.com";
```

### ファイル名
snake_case を使用します。

```
user_service.rs
auth_middleware.rs
```

## 所有権とライフタイム

### 所有権の移動
```rust
// ✅ 所有権の移動
fn process_user(user: User) {
    println!("{}", user.name);
}

let user = User::new("Alice");
process_user(user);
// user はここでは使えない
```

### 借用
```rust
// ✅ 不変参照
fn print_user(user: &User) {
    println!("{}", user.name);
}

// ✅ 可変参照
fn update_name(user: &mut User, name: String) {
    user.name = name;
}

let mut user = User::new("Alice");
print_user(&user);
update_name(&mut user, "Bob".to_string());
```

### ライフタイム
```rust
// ✅ 明示的なライフタイム
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

// ✅ 構造体のライフタイム
struct UserRef<'a> {
    name: &'a str,
}
```

## エラーハンドリング

### Result 型
```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file(path: &str) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}
```

### カスタムエラー
```rust
use std::fmt;

#[derive(Debug)]
enum AppError {
    NotFound(String),
    Validation { field: String, message: String },
    Database(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::NotFound(msg) => write!(f, "Not found: {}", msg),
            AppError::Validation { field, message } => {
                write!(f, "Validation error on {}: {}", field, message)
            }
            AppError::Database(msg) => write!(f, "Database error: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}

// 使用例
fn get_user(id: &str) -> Result<User, AppError> {
    if id.is_empty() {
        return Err(AppError::Validation {
            field: "id".to_string(),
            message: "ID is required".to_string(),
        });
    }
    // ...
}
```

### thiserror を活用
```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Validation error on {field}: {message}")]
    Validation { field: String, message: String },

    #[error("Database error")]
    Database(#[from] sqlx::Error),
}
```

## 構造体

### フィールドの可視性
```rust
pub struct User {
    pub id: String,
    pub name: String,
    email: String,  // プライベート
}

impl User {
    pub fn new(name: String, email: String) -> Self {
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            name,
            email,
        }
    }

    pub fn email(&self) -> &str {
        &self.email
    }
}
```

### Builder パターン
```rust
#[derive(Default)]
pub struct UserBuilder {
    name: Option<String>,
    email: Option<String>,
    age: Option<u32>,
}

impl UserBuilder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn name(mut self, name: String) -> Self {
        self.name = Some(name);
        self
    }

    pub fn email(mut self, email: String) -> Self {
        self.email = Some(email);
        self
    }

    pub fn age(mut self, age: u32) -> Self {
        self.age = Some(age);
        self
    }

    pub fn build(self) -> Result<User, AppError> {
        Ok(User {
            name: self.name.ok_or_else(|| AppError::Validation {
                field: "name".to_string(),
                message: "Name is required".to_string(),
            })?,
            email: self.email.ok_or_else(|| AppError::Validation {
                field: "email".to_string(),
                message: "Email is required".to_string(),
            })?,
            age: self.age.unwrap_or(0),
        })
    }
}

// 使用例
let user = UserBuilder::new()
    .name("Alice".to_string())
    .email("alice@example.com".to_string())
    .age(30)
    .build()?;
```

## トレイト

### トレイト実装
```rust
trait Repository {
    type Item;
    type Error;

    fn find_by_id(&self, id: &str) -> Result<Self::Item, Self::Error>;
    fn save(&self, item: &Self::Item) -> Result<(), Self::Error>;
}

struct UserRepository;

impl Repository for UserRepository {
    type Item = User;
    type Error = AppError;

    fn find_by_id(&self, id: &str) -> Result<User, AppError> {
        // ...
    }

    fn save(&self, user: &User) -> Result<(), AppError> {
        // ...
    }
}
```

### デフォルト実装
```rust
trait Validatable {
    fn validate(&self) -> Result<(), AppError>;

    fn is_valid(&self) -> bool {
        self.validate().is_ok()
    }
}
```

## Option と Result

### パターンマッチ
```rust
// ✅ match
match user {
    Some(u) => println!("User: {}", u.name),
    None => println!("User not found"),
}

// ✅ if let
if let Some(user) = get_user(id) {
    println!("User: {}", user.name);
}
```

### メソッドチェーン
```rust
// ✅ map, and_then, unwrap_or
let name = get_user(id)
    .map(|u| u.name)
    .unwrap_or_else(|| "Anonymous".to_string());

// ✅ ? 演算子
fn get_user_name(id: &str) -> Result<String, AppError> {
    let user = get_user(id)?;
    Ok(user.name)
}
```

## イテレータ

### イテレータの活用
```rust
// ✅ map, filter, collect
let names: Vec<String> = users
    .iter()
    .filter(|u| u.is_active)
    .map(|u| u.name.clone())
    .collect();

// ✅ fold
let total_age: u32 = users.iter().fold(0, |acc, u| acc + u.age);

// ✅ find
let alice = users.iter().find(|u| u.name == "Alice");
```

### 所有権を意識
```rust
// ✅ iter() - 借用
for user in users.iter() {
    println!("{}", user.name);
}

// ✅ iter_mut() - 可変借用
for user in users.iter_mut() {
    user.age += 1;
}

// ✅ into_iter() - 所有権移動
for user in users.into_iter() {
    process_user(user);
}
// users はここでは使えない
```

## 非同期処理

### async/await
```rust
use tokio;

async fn fetch_user(id: &str) -> Result<User, AppError> {
    let response = reqwest::get(format!("https://api.example.com/users/{}", id))
        .await?
        .json()
        .await?;
    Ok(response)
}

// 複数の非同期処理を並行実行
async fn fetch_multiple_users(ids: Vec<String>) -> Result<Vec<User>, AppError> {
    let tasks: Vec<_> = ids
        .into_iter()
        .map(|id| tokio::spawn(async move { fetch_user(&id).await }))
        .collect();

    let mut users = Vec::new();
    for task in tasks {
        users.push(task.await??);
    }
    Ok(users)
}
```

## マクロ

### println! / format!
```rust
let name = "Alice";
let age = 30;

println!("Name: {}, Age: {}", name, age);
println!("Name: {name}, Age: {age}");  // Rust 1.58+
```

### デバッグ出力
```rust
#[derive(Debug)]
struct User {
    name: String,
    age: u32,
}

let user = User { name: "Alice".to_string(), age: 30 };
println!("{:?}", user);   // デバッグ出力
println!("{:#?}", user);  // きれいな出力
```

## テスト

### 単体テスト
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_email_valid() {
        assert!(validate_email("user@example.com"));
    }

    #[test]
    fn test_validate_email_invalid() {
        assert!(!validate_email("invalid"));
    }

    #[test]
    #[should_panic(expected = "email is required")]
    fn test_create_user_no_email() {
        create_user("Alice", "");
    }
}
```

### 統合テスト
```rust
// tests/integration_test.rs
use my_crate::*;

#[test]
fn test_user_service() {
    let service = UserService::new();
    let user = service.create_user("Alice", "alice@example.com").unwrap();
    assert_eq!(user.name, "Alice");
}
```

### 非同期テスト
```rust
#[tokio::test]
async fn test_fetch_user() {
    let user = fetch_user("user-123").await.unwrap();
    assert_eq!(user.id, "user-123");
}
```

## ドキュメント

### ドキュメントコメント
```rust
/// ユーザーIDからユーザー情報を取得します
///
/// # Arguments
///
/// * `id` - ユーザーID
///
/// # Returns
///
/// * `Ok(User)` - ユーザー情報
/// * `Err(AppError)` - エラー
///
/// # Examples
///
/// ```
/// let user = get_user("user-123")?;
/// println!("{}", user.name);
/// ```
pub fn get_user(id: &str) -> Result<User, AppError> {
    // ...
}
```

## その他のベストプラクティス

### Clone を避ける
```rust
// ❌ 不要な Clone
fn process_name(name: String) {
    println!("{}", name);
}
let name = user.name.clone();
process_name(name);

// ✅ 借用
fn process_name(name: &str) {
    println!("{}", name);
}
process_name(&user.name);
```

### unwrap を避ける
```rust
// ❌ unwrap の多用
let user = get_user(id).unwrap();

// ✅ ? 演算子
let user = get_user(id)?;

// ✅ unwrap_or, unwrap_or_else
let user = get_user(id).unwrap_or_default();
```

### 型推論の活用
```rust
// ✅ 型推論
let users = vec![user1, user2, user3];

// ❌ 冗長な型注釈
let users: Vec<User> = vec![user1, user2, user3];
```

## チェックリスト

- [ ] cargo fmt でフォーマット
- [ ] cargo clippy でリント
- [ ] 所有権・借用ルールに従っている
- [ ] unwrap を避けている
- [ ] 公開APIにドキュメントを記載
- [ ] テストを作成
- [ ] エラーハンドリングが適切
