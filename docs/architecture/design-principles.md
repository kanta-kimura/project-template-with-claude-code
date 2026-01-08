# 設計原則

プロジェクトにおけるソフトウェア設計の基本原則です。

## SOLID 原則

### S: Single Responsibility Principle (単一責任の原則)

クラスや関数は1つの責任のみを持つべきです。

❌ 悪い例:
```typescript
class User {
  saveToDatabase() { /* ... */ }
  sendEmail() { /* ... */ }
  generateReport() { /* ... */ }
}
```

✅ 良い例:
```typescript
class User {
  // ユーザーのデータのみを管理
}

class UserRepository {
  save(user: User) { /* ... */ }
}

class EmailService {
  send(to: string, subject: string) { /* ... */ }
}

class ReportGenerator {
  generate(user: User) { /* ... */ }
}
```

### O: Open/Closed Principle (開放/閉鎖の原則)

拡張には開いているが、修正には閉じているべきです。

✅ 良い例:
```typescript
interface PaymentMethod {
  process(amount: number): void
}

class CreditCardPayment implements PaymentMethod {
  process(amount: number) {
    // クレジットカード決済
  }
}

class PayPalPayment implements PaymentMethod {
  process(amount: number) {
    // PayPal決済
  }
}

// 新しい決済方法を追加する際も既存コードを変更不要
class PaymentProcessor {
  constructor(private method: PaymentMethod) {}

  pay(amount: number) {
    this.method.process(amount)
  }
}
```

### L: Liskov Substitution Principle (リスコフの置換原則)

派生クラスは基底クラスと置き換え可能であるべきです。

### I: Interface Segregation Principle (インターフェース分離の原則)

クライアントは使用しないインターフェースに依存すべきではありません。

❌ 悪い例:
```typescript
interface Worker {
  work(): void
  eat(): void
  sleep(): void
}

class Robot implements Worker {
  work() { /* ... */ }
  eat() { throw new Error('Robots do not eat') }
  sleep() { throw new Error('Robots do not sleep') }
}
```

✅ 良い例:
```typescript
interface Workable {
  work(): void
}

interface Eatable {
  eat(): void
}

interface Sleepable {
  sleep(): void
}

class Robot implements Workable {
  work() { /* ... */ }
}

class Human implements Workable, Eatable, Sleepable {
  work() { /* ... */ }
  eat() { /* ... */ }
  sleep() { /* ... */ }
}
```

### D: Dependency Inversion Principle (依存性逆転の原則)

上位モジュールは下位モジュールに依存すべきではなく、両方とも抽象に依存すべきです。

✅ 良い例:
```typescript
// 抽象（インターフェース）
interface Database {
  save(data: any): void
  find(id: string): any
}

// 下位モジュール
class PostgresDatabase implements Database {
  save(data: any) { /* ... */ }
  find(id: string) { /* ... */ }
}

class MongoDatabase implements Database {
  save(data: any) { /* ... */ }
  find(id: string) { /* ... */ }
}

// 上位モジュール
class UserService {
  constructor(private db: Database) {} // 抽象に依存

  createUser(data: any) {
    this.db.save(data)
  }
}
```

## DRY (Don't Repeat Yourself)

重複を避け、コードを再利用します。

❌ 悪い例:
```typescript
function validateUserEmail(email: string) {
  return email.includes('@') && email.includes('.')
}

function validateAdminEmail(email: string) {
  return email.includes('@') && email.includes('.')
}
```

✅ 良い例:
```typescript
function validateEmail(email: string) {
  return email.includes('@') && email.includes('.')
}

// どこからでも使用可能
validateEmail(userEmail)
validateEmail(adminEmail)
```

**注意**: 3回繰り返したら共通化を検討しますが、無理な共通化は避けます。

## YAGNI (You Aren't Gonna Need It)

現時点で必要な機能のみを実装します。

❌ 悪い例:
```typescript
// 将来使うかもしれない機能を実装
class User {
  exportToXML() { /* 今は使わないが将来のため */ }
  exportToCSV() { /* 今は使わないが将来のため */ }
  exportToJSON() { /* これは実際に使う */ }
}
```

✅ 良い例:
```typescript
// 今必要な機能のみ
class User {
  exportToJSON() { /* 今使う */ }
}

// 必要になったときに追加
```

## KISS (Keep It Simple, Stupid)

シンプルに保ちます。

❌ 悪い例（過度な抽象化）:
```typescript
abstract class AbstractUserFactoryBuilder {
  abstract createFactory(): UserFactory
}

class UserFactory {
  createUser() { /* ... */ }
}
```

✅ 良い例:
```typescript
function createUser(name: string, email: string): User {
  return { name, email }
}
```

## 関心の分離 (Separation of Concerns)

異なる関心事は異なる場所で処理します。

✅ レイヤーの分離:
```
Controllers  ← HTTP リクエスト/レスポンス
Services     ← ビジネスロジック
Repositories ← データアクセス
Models       ← データ構造
```

## コンポジションオーバー継承

継承よりもコンポジションを優先します。

❌ 避けるべき:
```typescript
class Animal {
  eat() { /* ... */ }
}

class Dog extends Animal {
  bark() { /* ... */ }
}

class Bird extends Animal {
  fly() { /* ... */ }
}

// では飛べる犬は？継承だと困難
```

✅ 推奨:
```typescript
interface Eatable {
  eat(): void
}

interface Flyable {
  fly(): void
}

interface Barkable {
  bark(): void
}

class Dog implements Eatable, Barkable {
  eat() { /* ... */ }
  bark() { /* ... */ }
}

class Bird implements Eatable, Flyable {
  eat() { /* ... */ }
  fly() { /* ... */ }
}

// 飛べる犬も簡単に実装可能
class FlyingDog implements Eatable, Flyable, Barkable {
  eat() { /* ... */ }
  fly() { /* ... */ }
  bark() { /* ... */ }
}
```

## イミュータビリティ

可能な限り、不変なデータ構造を使用します。

✅ 推奨:
```typescript
// イミュータブル
const user = { name: 'Alice', age: 30 }
const updatedUser = { ...user, age: 31 }

// 元のオブジェクトは変更されない
console.log(user.age) // 30
console.log(updatedUser.age) // 31
```

❌ 避ける:
```typescript
// ミュータブル
const user = { name: 'Alice', age: 30 }
user.age = 31 // 元のオブジェクトを変更
```

## 早期リターン

ネストを減らすため、早期リターンを活用します。

❌ ネストが深い:
```typescript
function processUser(user: User) {
  if (user) {
    if (user.isActive) {
      if (user.email) {
        sendEmail(user.email)
      }
    }
  }
}
```

✅ 早期リターン:
```typescript
function processUser(user: User) {
  if (!user) return
  if (!user.isActive) return
  if (!user.email) return

  sendEmail(user.email)
}
```

## 小さな関数

関数は小さく保ちます。目安は20行程度。

✅ 良い例:
```typescript
function createUser(data: CreateUserInput): User {
  validateUserInput(data)
  const hashedPassword = hashPassword(data.password)
  return saveUser({ ...data, password: hashedPassword })
}

function validateUserInput(data: CreateUserInput) {
  if (!data.email) throw new Error('Email required')
  if (!data.password) throw new Error('Password required')
}

function hashPassword(password: string): string {
  return bcrypt.hash(password, 10)
}

function saveUser(user: User): User {
  return repository.save(user)
}
```

## 命名

### 意味のある名前

```typescript
// ❌ 悪い
const d = new Date()
const temp = data.filter(x => x.a > 10)

// ✅ 良い
const currentDate = new Date()
const activeUsers = users.filter(user => user.loginCount > 10)
```

### 動詞 + 名詞

関数名は動詞で始めます。

```typescript
// ✅ 良い
getUser()
createOrder()
deleteAccount()
validateEmail()
```

## エラーハンドリング

### 具体的なエラー

```typescript
// ❌ 一般的すぎる
throw new Error('Error')

// ✅ 具体的
throw new UserNotFoundError(`User not found: ${userId}`)
```

### エラーの伝播

```typescript
// ✅ エラーをラップして伝播
async function getUser(id: string): Promise<User> {
  try {
    return await repository.findById(id)
  } catch (error) {
    throw new ServiceError(`Failed to get user: ${id}`, error)
  }
}
```

## テスタビリティ

### 依存性注入

```typescript
// ✅ テスト可能
class UserService {
  constructor(private repository: UserRepository) {}

  async getUser(id: string) {
    return this.repository.findById(id)
  }
}

// テスト時にモックを注入
const mockRepository = { findById: jest.fn() }
const service = new UserService(mockRepository)
```

### 純粋関数

```typescript
// ✅ 純粋関数（テストしやすい）
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// ❌ 副作用あり（テストしにくい）
let total = 0
function calculateTotal(items: Item[]) {
  items.forEach(item => {
    total += item.price
  })
}
```

## パフォーマンス

### 測定してから最適化

```typescript
// まず動くコードを書く
function findUser(id: string) {
  return users.find(u => u.id === id)
}

// 遅いことが測定で分かったら最適化
function findUser(id: string) {
  return userMap.get(id) // O(1)
}
```

### N+1 問題を避ける

```typescript
// ❌ N+1 問題
for (const user of users) {
  user.posts = await db.query('SELECT * FROM posts WHERE user_id = ?', [user.id])
}

// ✅ 一度にクエリ
const userIds = users.map(u => u.id)
const posts = await db.query('SELECT * FROM posts WHERE user_id IN (?)', [userIds])
const postsByUser = groupBy(posts, 'user_id')
users.forEach(user => {
  user.posts = postsByUser[user.id] || []
})
```

## セキュリティ

設計段階からセキュリティを考慮します。

詳細は `docs/rules/security.md` を参照。

## まとめ

これらの原則はガイドラインであり、絶対的なルールではありません。
状況に応じて適切に適用してください。

**重要なのは**:
- コードの可読性
- 保守性
- テスタビリティ
- シンプルさ

過度な抽象化や最適化は避け、まずシンプルで動くコードを書きましょう。
