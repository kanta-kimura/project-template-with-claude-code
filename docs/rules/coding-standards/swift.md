# Swift コーディング規約

## 概要

Swift プロジェクトのコーディング規約です。
基本的に Swift API Design Guidelines に従います。

## 基本設定

### Swift バージョン
Swift 5.9 以上を使用します。

### リンター
SwiftLint を使用します。

```bash
# インストール
brew install swiftlint

# 実行
swiftlint
```

### フォーマッタ
swift-format を使用します。

```bash
# インストール
brew install swift-format

# 実行
swift-format -i **/*.swift
```

## 命名規則

### 変数・関数・プロパティ
lowerCamelCase を使用します。

```swift
let userName = "Alice"
var isActive = true

func getUserById(id: String) -> User? {
    // ...
}
```

### クラス・構造体・列挙型・プロトコル
UpperCamelCase を使用します。

```swift
class UserService {
    // ...
}

struct User {
    // ...
}

enum UserRole {
    case admin
    case user
}

protocol UserRepository {
    func findById(id: String) -> User?
}
```

### 定数
lowerCamelCase を使用します（Swift では UPPER_SNAKE_CASE は使用しない）。

```swift
let maxRetryCount = 3
let apiBaseURL = "https://api.example.com"

// グローバル定数
private let defaultTimeout: TimeInterval = 30.0
```

### プライベート
`private` または `fileprivate` を使用します。

```swift
class User {
    private var password: String  // クラス内のみ
    fileprivate var internalId: String  // ファイル内のみ

    private func hashPassword() {
        // ...
    }
}
```

### ファイル名
UpperCamelCase を使用します。

```
UserService.swift
AuthMiddleware.swift
```

## 型システム

### 型推論の活用
```swift
// ✅ 型推論
let name = "Alice"
let items = [1, 2, 3]
let user = User(name: "Alice")

// ❌ 冗長な型注釈
let name: String = "Alice"
let items: [Int] = [1, 2, 3]
```

### Optional の扱い

#### Optional Binding
```swift
// ✅ if let
if let user = getUser(id: "123") {
    print(user.name)
}

// ✅ guard let（早期リターン）
guard let user = getUser(id: "123") else {
    return
}
print(user.name)

// ❌ 強制アンラップ（避ける）
let user = getUser(id: "123")!
```

#### Optional Chaining
```swift
// ✅ Optional Chaining
let name = user?.profile?.name

// ✅ Nil Coalescing
let name = user?.name ?? "Anonymous"
```

### 型キャスト
```swift
// ✅ 安全なキャスト
if let label = view as? UILabel {
    label.text = "Hello"
}

// ✅ guard での型キャスト
guard let label = view as? UILabel else {
    return
}
label.text = "Hello"

// ❌ 強制キャスト（避ける）
let label = view as! UILabel
```

## 構造体 vs クラス

### 構造体を優先
値型が適している場合は構造体を使用します。

```swift
// ✅ 構造体（値型）
struct User {
    let id: String
    let name: String
    let email: String
}

// ✅ イミュータブル
let user = User(id: "1", name: "Alice", email: "alice@example.com")
// user.name = "Bob"  // エラー：let で宣言されているため変更不可
```

### クラスを使用する場合
- 継承が必要
- 参照セマンティクスが必要
- デイニシャライザが必要

```swift
class ViewController: UIViewController {
    // 継承が必要なため class
}

class UserSession {
    // 参照型として扱いたい場合
    var currentUser: User?
}
```

## プロパティ

### Computed Property
```swift
struct Rectangle {
    var width: Double
    var height: Double

    // ✅ Computed Property
    var area: Double {
        return width * height
    }

    // ✅ Read-only Computed Property（get のみ）
    var perimeter: Double {
        width * 2 + height * 2  // return は省略可能
    }
}
```

### Property Observer
```swift
class User {
    var name: String {
        didSet {
            print("Name changed from \(oldValue) to \(name)")
        }
    }

    var age: Int {
        willSet {
            print("Age will change to \(newValue)")
        }
    }
}
```

### Lazy Property
```swift
class DataManager {
    // ✅ 遅延初期化（最初のアクセス時に計算）
    lazy var expensiveData: [String] = {
        // 重い処理
        return loadData()
    }()
}
```

## 関数

### 引数ラベル
```swift
// ✅ 外部引数名と内部引数名
func greet(person name: String, from hometown: String) {
    print("Hello \(name)! From \(hometown)")
}

greet(person: "Alice", from: "Tokyo")

// ✅ 外部引数名を省略
func sum(_ a: Int, _ b: Int) -> Int {
    return a + b
}

sum(5, 3)
```

### デフォルト引数
```swift
// ✅ デフォルト値
func greet(name: String, greeting: String = "Hello") {
    print("\(greeting), \(name)!")
}

greet(name: "Alice")  // "Hello, Alice!"
greet(name: "Bob", greeting: "Hi")  // "Hi, Bob!"
```

### 可変長引数
```swift
func sum(_ numbers: Int...) -> Int {
    return numbers.reduce(0, +)
}

sum(1, 2, 3, 4, 5)  // 15
```

### inout パラメータ
```swift
func swap(_ a: inout Int, _ b: inout Int) {
    let temp = a
    a = b
    b = temp
}

var x = 5
var y = 10
swap(&x, &y)
```

## クロージャ

### 基本形
```swift
// ✅ クロージャ
let names = ["Alice", "Bob", "Carol"]
let sortedNames = names.sorted { $0 < $1 }

// ✅ トレーリングクロージャ
let filtered = names.filter { name in
    name.count > 3
}

// ✅ 省略形
let mapped = names.map { $0.uppercased() }
```

### Escaping クロージャ
```swift
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
    DispatchQueue.global().async {
        // 非同期処理
        let result = /* ... */
        completion(result)
    }
}
```

### Capture List
```swift
class ViewController {
    var name = "ViewController"

    func setupHandler() {
        // ✅ weak self で循環参照を防ぐ
        someButton.tapHandler = { [weak self] in
            guard let self = self else { return }
            print(self.name)
        }

        // ✅ unowned（self が必ず存在する場合）
        someButton.tapHandler = { [unowned self] in
            print(self.name)
        }
    }
}
```

## プロトコル

### プロトコル定義
```swift
protocol UserRepository {
    func findById(id: String) -> User?
    func save(user: User) throws
}

// ✅ プロトコル準拠
class InMemoryUserRepository: UserRepository {
    func findById(id: String) -> User? {
        // ...
    }

    func save(user: User) throws {
        // ...
    }
}
```

### プロトコル拡張
```swift
protocol Validatable {
    func validate() throws
}

// ✅ デフォルト実装
extension Validatable {
    func isValid() -> Bool {
        do {
            try validate()
            return true
        } catch {
            return false
        }
    }
}
```

### Protocol Composition
```swift
protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

// ✅ 複数のプロトコルを組み合わせ
func celebrate(person: Named & Aged) {
    print("\(person.name) is \(person.age) years old!")
}
```

## 列挙型

### 基本的な列挙型
```swift
enum UserRole {
    case admin
    case user
    case guest
}

// ✅ Raw Value
enum HttpStatusCode: Int {
    case ok = 200
    case notFound = 404
    case serverError = 500
}
```

### Associated Value
```swift
// ✅ 関連値
enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

let result: Result<User, Error> = .success(user)

switch result {
case .success(let user):
    print("Success: \(user.name)")
case .failure(let error):
    print("Error: \(error)")
}
```

### Computed Property
```swift
enum UserRole {
    case admin
    case user
    case guest

    var permissions: [String] {
        switch self {
        case .admin:
            return ["read", "write", "delete"]
        case .user:
            return ["read", "write"]
        case .guest:
            return ["read"]
        }
    }
}
```

## エラーハンドリング

### Error プロトコル
```swift
enum ValidationError: Error {
    case invalidEmail
    case passwordTooShort
    case usernameTaken
}

// ✅ エラーを投げる
func validateEmail(_ email: String) throws {
    guard email.contains("@") else {
        throw ValidationError.invalidEmail
    }
}
```

### do-catch
```swift
// ✅ エラーハンドリング
do {
    try validateEmail(email)
    try createUser(email: email)
} catch ValidationError.invalidEmail {
    print("Invalid email format")
} catch ValidationError.passwordTooShort {
    print("Password is too short")
} catch {
    print("Unknown error: \(error)")
}
```

### try?, try!
```swift
// ✅ try?（エラーを Optional に変換）
if let user = try? fetchUser(id: "123") {
    print(user.name)
}

// ❌ try!（エラーが発生したらクラッシュ）
let user = try! fetchUser(id: "123")  // 使用は避ける
```

### Result 型
```swift
func fetchUser(id: String) -> Result<User, Error> {
    do {
        let user = try loadUser(id: id)
        return .success(user)
    } catch {
        return .failure(error)
    }
}

// 使用例
switch fetchUser(id: "123") {
case .success(let user):
    print(user.name)
case .failure(let error):
    print("Error: \(error)")
}
```

## 非同期処理

### async/await (Swift 5.5+)
```swift
// ✅ async 関数
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// ✅ 使用例
Task {
    do {
        let user = try await fetchUser(id: "123")
        print(user.name)
    } catch {
        print("Error: \(error)")
    }
}
```

### 並行処理
```swift
// ✅ 並行実行
func fetchMultipleUsers(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }

        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

### MainActor
```swift
// ✅ メインスレッドで実行
@MainActor
func updateUI() {
    // UI 更新処理
    label.text = "Updated"
}

// ✅ 一部のみメインスレッド
func fetchAndUpdate() async {
    let data = await fetchData()

    await MainActor.run {
        // UI 更新
        label.text = data
    }
}
```

## メモリ管理

### ARC (Automatic Reference Counting)
```swift
// ✅ weak 参照（循環参照を防ぐ）
class Parent {
    var child: Child?
}

class Child {
    weak var parent: Parent?  // weak で循環参照を防ぐ
}

// ✅ unowned（必ず存在することが保証される場合）
class Customer {
    var card: CreditCard?
}

class CreditCard {
    unowned let customer: Customer  // customer は必ず存在

    init(customer: Customer) {
        self.customer = customer
    }
}
```

### クロージャでのキャプチャ
```swift
class ViewController {
    var completion: (() -> Void)?

    func setup() {
        // ❌ 循環参照
        completion = {
            self.doSomething()
        }

        // ✅ weak self
        completion = { [weak self] in
            self?.doSomething()
        }

        // ✅ guard let
        completion = { [weak self] in
            guard let self = self else { return }
            self.doSomething()
        }
    }
}
```

## コレクション

### 配列操作
```swift
let numbers = [1, 2, 3, 4, 5]

// ✅ map
let doubled = numbers.map { $0 * 2 }

// ✅ filter
let evens = numbers.filter { $0 % 2 == 0 }

// ✅ reduce
let sum = numbers.reduce(0, +)

// ✅ compactMap（nil を除外）
let strings = ["1", "2", "three", "4"]
let validNumbers = strings.compactMap { Int($0) }  // [1, 2, 4]

// ✅ flatMap（ネストを平坦化）
let nested = [[1, 2], [3, 4], [5, 6]]
let flattened = nested.flatMap { $0 }  // [1, 2, 3, 4, 5, 6]
```

### 高階関数の連鎖
```swift
let result = numbers
    .filter { $0 % 2 == 0 }
    .map { $0 * 2 }
    .reduce(0, +)
```

## 拡張 (Extension)

### 既存型の拡張
```swift
// ✅ String の拡張
extension String {
    var isValidEmail: Bool {
        contains("@") && contains(".")
    }

    func trimmed() -> String {
        trimmingCharacters(in: .whitespaces)
    }
}

// 使用例
let email = "user@example.com"
if email.isValidEmail {
    print("Valid email")
}
```

### プロトコル準拠を拡張で追加
```swift
struct User {
    let id: String
    let name: String
}

// ✅ 拡張でプロトコル準拠を追加
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
```

## Codable

### JSON エンコード・デコード
```swift
struct User: Codable {
    let id: String
    let name: String
    let email: String
}

// ✅ デコード
let json = """
{
    "id": "123",
    "name": "Alice",
    "email": "alice@example.com"
}
"""

let data = json.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: data)

// ✅ エンコード
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let encoded = try encoder.encode(user)
```

### カスタムキー
```swift
struct User: Codable {
    let id: String
    let name: String
    let emailAddress: String

    // ✅ JSON のキーと Swift のプロパティ名が異なる場合
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emailAddress = "email"
    }
}
```

## アクセス制御

### アクセスレベル
```swift
open class OpenClass {  // モジュール外で継承可能
    open func openMethod() {}
}

public class PublicClass {  // モジュール外からアクセス可能（継承不可）
    public func publicMethod() {}
}

internal class InternalClass {  // モジュール内のみ（デフォルト）
    func internalMethod() {}
}

fileprivate class FilePrivateClass {  // ファイル内のみ
    func filePrivateMethod() {}
}

private class PrivateClass {  // スコープ内のみ
    func privateMethod() {}
}
```

## SwiftUI

### View の定義
```swift
import SwiftUI

struct ContentView: View {
    @State private var name = ""

    var body: some View {
        VStack {
            TextField("Name", text: $name)
            Text("Hello, \(name)!")
        }
        .padding()
    }
}
```

### @State, @Binding, @ObservedObject
```swift
// ✅ @State（View 内の状態）
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}

// ✅ @Binding（親から渡される値）
struct ChildView: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Switch", isOn: $isOn)
    }
}

// ✅ @ObservedObject（外部のオブジェクト）
class ViewModel: ObservableObject {
    @Published var count = 0
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Text("Count: \(viewModel.count)")
    }
}
```

## テスト

### XCTest
```swift
import XCTest
@testable import MyApp

class UserServiceTests: XCTestCase {
    var sut: UserService!

    override func setUp() {
        super.setUp()
        sut = UserService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateUser() {
        // Given
        let name = "Alice"
        let email = "alice@example.com"

        // When
        let user = sut.createUser(name: name, email: email)

        // Then
        XCTAssertNotNil(user)
        XCTAssertEqual(user.name, name)
        XCTAssertEqual(user.email, email)
    }

    func testCreateUserWithInvalidEmail() {
        // Given
        let name = "Bob"
        let invalidEmail = "invalid"

        // Then
        XCTAssertThrowsError(
            try sut.createUser(name: name, email: invalidEmail)
        ) { error in
            XCTAssertEqual(error as? ValidationError, .invalidEmail)
        }
    }
}
```

### 非同期テスト
```swift
func testAsyncFetchUser() async throws {
    // When
    let user = try await userService.fetchUser(id: "123")

    // Then
    XCTAssertEqual(user.id, "123")
    XCTAssertNotNil(user.name)
}
```

## ドキュメント

### コメント
```swift
/// ユーザーIDからユーザー情報を取得します
///
/// - Parameter id: ユーザーID
/// - Returns: ユーザー情報。見つからない場合は nil
/// - Throws: `NetworkError` ネットワークエラーが発生した場合
func fetchUser(id: String) async throws -> User? {
    // ...
}
```

## チェックリスト

- [ ] SwiftLint でリント
- [ ] swift-format でフォーマット
- [ ] 強制アンラップ（!）を避ける
- [ ] 強制キャスト（as!）を避ける
- [ ] weak/unowned で循環参照を防ぐ
- [ ] 公開APIにドキュメントコメントを記載
- [ ] テストを作成
- [ ] アクセス制御が適切
