# Java コーディング規約

## 概要

Java プロジェクトのコーディング規約です。
基本的に Google Java Style Guide に従います。

## 基本設定

### Java バージョン
Java 17 以上を使用します。

### フォーマッタ
google-java-format を使用します。

```bash
java -jar google-java-format.jar --replace **/*.java
```

### ビルドツール
Maven または Gradle を使用します。

## 命名規則

### 変数・メソッド
camelCase を使用します。

```java
String userName = "Alice";
boolean isActive = true;

public User getUserById(String userId) {
    // ...
}
```

### クラス・インターフェース
PascalCase を使用します。

```java
public class UserService {
    // ...
}

public interface UserRepository {
    // ...
}

public enum UserRole {
    ADMIN,
    USER
}
```

### 定数
UPPER_SNAKE_CASE を使用します。

```java
public static final int MAX_RETRY_COUNT = 3;
public static final String API_BASE_URL = "https://api.example.com";
```

### パッケージ名
すべて小文字を使用します。

```java
package com.example.userservice;
package com.example.auth.middleware;
```

### ファイル名
クラス名と同じ PascalCase を使用します。

```
UserService.java
AuthMiddleware.java
```

## クラス設計

### 単一責任の原則
```java
// ✅ 単一責任
public class UserRepository {
    public User findById(String id) {
        // データベースアクセスのみ
    }

    public void save(User user) {
        // 保存処理のみ
    }
}

public class UserValidator {
    public void validate(User user) {
        // バリデーションのみ
    }
}
```

### イミュータブル
```java
// ✅ イミュータブルクラス
public final class User {
    private final String id;
    private final String name;
    private final String email;

    public User(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }

    // 変更が必要な場合は新しいインスタンスを返す
    public User withName(String newName) {
        return new User(this.id, newName, this.email);
    }
}
```

### Record (Java 14+)
```java
// ✅ Record でイミュータブルクラスを簡潔に
public record User(String id, String name, String email) {
    // カスタムバリデーション
    public User {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
    }
}
```

## メソッド

### 小さく保つ
```java
// ✅ 単一の責任
public boolean validateEmail(String email) {
    return email != null && email.contains("@");
}

public User createUser(String email, String name) {
    if (!validateEmail(email)) {
        throw new ValidationException("Invalid email");
    }
    return new User(generateId(), name, email);
}
```

### メソッド引数
引数が多い場合はBuilderパターンを使用します。

```java
// ❌ 引数が多すぎる
public User createUser(String name, String email, int age, String address, String phone) {
    // ...
}

// ✅ Builder パターン
public class User {
    private String name;
    private String email;
    private int age;
    private String address;
    private String phone;

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String name;
        private String email;
        private int age;
        private String address;
        private String phone;

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder email(String email) {
            this.email = email;
            return this;
        }

        public Builder age(int age) {
            this.age = age;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }
}

// 使用例
User user = User.builder()
    .name("Alice")
    .email("alice@example.com")
    .age(30)
    .build();
```

### Lombok を活用
```java
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class User {
    private String id;
    private String name;
    private String email;
    private int age;
}

// 使用例
User user = User.builder()
    .name("Alice")
    .email("alice@example.com")
    .build();
```

## 例外処理

### チェック例外 vs 非チェック例外
```java
// ✅ ビジネスロジックエラー：チェック例外
public class UserNotFoundException extends Exception {
    public UserNotFoundException(String userId) {
        super("User not found: " + userId);
    }
}

// ✅ プログラミングエラー：非チェック例外
public class ValidationException extends RuntimeException {
    public ValidationException(String message) {
        super(message);
    }
}
```

### try-with-resources
```java
// ✅ リソース管理
public String readFile(String path) throws IOException {
    try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
        return reader.lines().collect(Collectors.joining("\n"));
    }
}
```

### 例外の再スロー
```java
// ✅ 例外をラップ
public User getUser(String id) throws ServiceException {
    try {
        return repository.findById(id);
    } catch (SQLException e) {
        throw new ServiceException("Failed to get user: " + id, e);
    }
}
```

## コレクション

### List, Set, Map
```java
// ✅ インターフェース型で宣言
List<User> users = new ArrayList<>();
Set<String> userIds = new HashSet<>();
Map<String, User> userMap = new HashMap<>();

// ✅ イミュータブルコレクション (Java 9+)
List<String> names = List.of("Alice", "Bob", "Carol");
Set<Integer> numbers = Set.of(1, 2, 3);
Map<String, Integer> scores = Map.of("Alice", 100, "Bob", 90);
```

### Stream API
```java
// ✅ Stream の活用
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .collect(Collectors.toList());

// ✅ reduce
int totalAge = users.stream()
    .mapToInt(User::getAge)
    .sum();

// ✅ groupingBy
Map<String, List<User>> usersByRole = users.stream()
    .collect(Collectors.groupingBy(User::getRole));
```

## Optional

### Null の代わりに Optional
```java
// ❌ null を返す
public User findUser(String id) {
    return users.get(id);  // null の可能性
}

// ✅ Optional を返す
public Optional<User> findUser(String id) {
    return Optional.ofNullable(users.get(id));
}

// 使用例
Optional<User> user = findUser("user-123");
user.ifPresent(u -> System.out.println(u.getName()));

String name = user
    .map(User::getName)
    .orElse("Anonymous");
```

## 並行処理

### スレッドセーフ
```java
// ✅ synchronized
public class Counter {
    private int count = 0;

    public synchronized void increment() {
        count++;
    }

    public synchronized int getCount() {
        return count;
    }
}

// ✅ AtomicInteger
public class Counter {
    private AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();
    }

    public int getCount() {
        return count.get();
    }
}
```

### ExecutorService
```java
// ✅ スレッドプール
ExecutorService executor = Executors.newFixedThreadPool(10);

try {
    List<Future<User>> futures = userIds.stream()
        .map(id -> executor.submit(() -> fetchUser(id)))
        .collect(Collectors.toList());

    for (Future<User> future : futures) {
        User user = future.get();
        processUser(user);
    }
} finally {
    executor.shutdown();
}
```

### CompletableFuture
```java
// ✅ 非同期処理
CompletableFuture<User> userFuture = CompletableFuture
    .supplyAsync(() -> fetchUser(userId))
    .thenApply(user -> enrichUser(user))
    .exceptionally(ex -> {
        log.error("Failed to fetch user", ex);
        return getDefaultUser();
    });

User user = userFuture.get();
```

## インターフェース

### デフォルトメソッド (Java 8+)
```java
public interface UserRepository {
    User findById(String id);
    void save(User user);

    // デフォルト実装
    default boolean exists(String id) {
        return findById(id) != null;
    }
}
```

### 関数型インターフェース
```java
@FunctionalInterface
public interface UserProcessor {
    void process(User user);
}

// 使用例
UserProcessor processor = user -> System.out.println(user.getName());

// または
users.forEach(user -> System.out.println(user.getName()));
```

## アノテーション

### Spring Framework
```java
@Service
public class UserService {
    private final UserRepository repository;

    @Autowired
    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public User createUser(User user) {
        validate(user);
        return repository.save(user);
    }
}

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService service;

    @Autowired
    public UserController(UserService service) {
        this.service = service;
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable String id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
```

### Bean Validation
```java
public class User {
    @NotNull
    @Size(min = 1, max = 100)
    private String name;

    @NotNull
    @Email
    private String email;

    @Min(0)
    @Max(150)
    private int age;
}
```

## テスト

### JUnit 5
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class UserServiceTest {
    private UserService service;

    @BeforeEach
    void setUp() {
        service = new UserService(new InMemoryUserRepository());
    }

    @Test
    void testCreateUser() {
        User user = service.createUser("Alice", "alice@example.com");
        assertNotNull(user.getId());
        assertEquals("Alice", user.getName());
    }

    @Test
    void testCreateUserInvalidEmail() {
        assertThrows(ValidationException.class, () -> {
            service.createUser("Alice", "invalid-email");
        });
    }
}
```

### Mockito
```java
import static org.mockito.Mockito.*;

class UserServiceTest {
    @Test
    void testGetUser() {
        UserRepository repository = mock(UserRepository.class);
        User expectedUser = new User("1", "Alice", "alice@example.com");
        when(repository.findById("1")).thenReturn(Optional.of(expectedUser));

        UserService service = new UserService(repository);
        Optional<User> user = service.getUser("1");

        assertTrue(user.isPresent());
        assertEquals("Alice", user.get().getName());
        verify(repository).findById("1");
    }
}
```

## ロギング

### SLF4J
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    public User createUser(User user) {
        log.info("Creating user: {}", user.getEmail());
        try {
            User created = repository.save(user);
            log.debug("User created: {}", created.getId());
            return created;
        } catch (Exception e) {
            log.error("Failed to create user: {}", user.getEmail(), e);
            throw e;
        }
    }
}
```

## その他のベストプラクティス

### equals と hashCode
```java
// ✅ Lombok
@Data
public class User {
    private String id;
    private String name;
}

// ✅ 手動実装
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    User user = (User) o;
    return Objects.equals(id, user.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}
```

### toString
```java
// ✅ Lombok
@ToString
public class User {
    private String id;
    private String name;
}

// ✅ 手動実装
@Override
public String toString() {
    return "User{id='" + id + "', name='" + name + "'}";
}
```

## チェックリスト

- [ ] google-java-format でフォーマット
- [ ] すべての例外を適切に処理
- [ ] リソースを try-with-resources で管理
- [ ] Stream API を活用
- [ ] Optional を活用して null を避ける
- [ ] テストを作成
- [ ] ログ出力が適切
