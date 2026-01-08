# テストポリシー

プロジェクトにおけるテスト戦略とカバレッジ基準を定義します。

## テストの目的

1. **品質保証**: バグの早期発見と防止
2. **リファクタリングの安全性**: 安心してコード改善ができる
3. **ドキュメント**: テストがコードの使い方を示す
4. **設計の改善**: テストしやすい設計を促進

## テストの種類

### 1. 単体テスト (Unit Test)

**対象**: 個々の関数・メソッド・クラス

**目的**: 最小単位の動作を検証

**特徴**:
- 高速に実行
- 外部依存をモック化
- 1つの機能を1つのテストで検証

**例**:
```typescript
describe('validateEmail', () => {
  test('有効なメールアドレスの場合はtrueを返す', () => {
    expect(validateEmail('user@example.com')).toBe(true)
  })

  test('無効なメールアドレスの場合はfalseを返す', () => {
    expect(validateEmail('invalid')).toBe(false)
  })
})
```

**カバレッジ目標**: 80% 以上

### 2. 統合テスト (Integration Test)

**対象**: 複数のコンポーネント間の連携

**目的**: モジュール間の統合を検証

**特徴**:
- データベース接続を含む
- API呼び出しを含む
- 複数のクラス・モジュールを組み合わせて検証

**例**:
```typescript
describe('UserService', () => {
  test('ユーザーを作成してデータベースに保存できる', async () => {
    const user = await userService.create({
      name: 'Alice',
      email: 'alice@example.com'
    })

    const saved = await userRepository.findById(user.id)
    expect(saved).toBeDefined()
    expect(saved.name).toBe('Alice')
  })
})
```

**カバレッジ目標**: 主要なフロー 100%

### 3. E2E テスト (End-to-End Test)

**対象**: ユーザーの操作フロー全体

**目的**: システム全体の動作を検証

**特徴**:
- ブラウザ操作を含む
- 実際のユーザー操作をシミュレート
- 最も遅い

**例**:
```typescript
test('ユーザー登録フロー', async () => {
  await page.goto('/signup')
  await page.fill('[name=email]', 'user@example.com')
  await page.fill('[name=password]', 'SecurePass123')
  await page.click('button[type=submit]')

  await page.waitForURL('/dashboard')
  expect(await page.textContent('h1')).toBe('ダッシュボード')
})
```

**カバレッジ目標**: 主要なユーザーフロー 100%

## カバレッジ基準

### 最低基準

| 種類 | カバレッジ | 備考 |
|------|-----------|------|
| ステートメント | 80% | すべての行の80%が実行される |
| ブランチ | 75% | すべての分岐の75%が実行される |
| 関数 | 80% | すべての関数の80%が実行される |
| 行 | 80% | すべての行の80%が実行される |

### 必須テスト

以下は100%カバレッジが必須:

- **ビジネスロジック**: 計算、検証、変換など
- **セキュリティ関連**: 認証、認可、入力検証
- **決済・金融処理**: 金額計算、トランザクション
- **公開API**: 外部に公開するインターフェース

### テスト不要

以下はテスト不要またはカバレッジから除外:

- 自動生成コード
- 外部ライブラリのラッパー（薄いラッパー）
- 設定ファイル
- 型定義のみのファイル

## テストの書き方

### AAA パターン

```
Arrange (準備) → Act (実行) → Assert (検証)
```

```typescript
test('ユーザーを作成できる', async () => {
  // Arrange: テストデータを準備
  const userData = {
    name: 'Alice',
    email: 'alice@example.com'
  }

  // Act: テスト対象を実行
  const user = await createUser(userData)

  // Assert: 結果を検証
  expect(user.id).toBeDefined()
  expect(user.name).toBe('Alice')
})
```

### テスト名の規則

**パターン**: `[対象] [条件] [期待結果]`

✅ 良い例:
```typescript
test('validateEmail は有効なメールアドレスの場合trueを返す')
test('createUser はメールアドレスが重複している場合エラーをスローする')
test('getUser は存在しないIDの場合nullを返す')
```

❌ 悪い例:
```typescript
test('テスト1')
test('動作確認')
test('バグ修正')
```

### 1テスト1アサーション

可能な限り、1つのテストで1つのことだけを検証します。

```typescript
// ✅ 良い例
test('作成されたユーザーはIDを持つ', () => {
  expect(user.id).toBeDefined()
})

test('作成されたユーザーは正しい名前を持つ', () => {
  expect(user.name).toBe('Alice')
})

// ❌ 悪い例（複数の検証が混在）
test('ユーザーを作成できる', () => {
  expect(user.id).toBeDefined()
  expect(user.name).toBe('Alice')
  expect(user.email).toBe('alice@example.com')
  expect(user.createdAt).toBeInstanceOf(Date)
})
```

ただし、関連する検証は1つのテストにまとめても良い。

## テストデータ

### ファクトリパターン

```typescript
// test/factories/user-factory.ts
export const createTestUser = (overrides = {}) => ({
  id: 'user-123',
  name: 'Test User',
  email: 'test@example.com',
  ...overrides
})

// 使用例
const user = createTestUser({ name: 'Alice' })
```

### フィクスチャ

```typescript
// test/fixtures/users.json
[
  {
    "id": "user-1",
    "name": "Alice",
    "email": "alice@example.com"
  },
  {
    "id": "user-2",
    "name": "Bob",
    "email": "bob@example.com"
  }
]

// 使用例
import users from './fixtures/users.json'
```

## モック・スタブ

### モックの使用

外部依存はモック化します。

```typescript
// データベースのモック
jest.mock('./database', () => ({
  query: jest.fn()
}))

test('ユーザーを取得できる', async () => {
  const mockQuery = require('./database').query
  mockQuery.mockResolvedValue({ id: '1', name: 'Alice' })

  const user = await getUser('1')

  expect(user.name).toBe('Alice')
  expect(mockQuery).toHaveBeenCalledWith('SELECT * FROM users WHERE id = ?', ['1'])
})
```

### 依存性注入

テストしやすい設計のため、依存性注入を活用します。

```typescript
// ✅ 依存性注入
class UserService {
  constructor(private repository: UserRepository) {}

  async getUser(id: string) {
    return this.repository.findById(id)
  }
}

// テスト時にモックを注入
const mockRepository = {
  findById: jest.fn()
}
const service = new UserService(mockRepository)
```

## テストの実行

### ローカル環境

```bash
# すべてのテストを実行
npm test

# watch モード
npm test -- --watch

# カバレッジ付き
npm test -- --coverage

# 特定のファイルのみ
npm test user.test.ts
```

### CI/CD

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test -- --coverage
      - name: Check coverage
        run: |
          if [ $(npm test -- --coverage --silent | grep "All files" | awk '{print $4}' | sed 's/%//') -lt 80 ]; then
            echo "Coverage is below 80%"
            exit 1
          fi
```

## テスト戦略

### テストピラミッド

```
        /\
       /E2E\       少ない（遅い）
      /------\
     /統合テスト\    中程度
    /----------\
   /  単体テスト  \  多い（速い）
  /--------------\
```

**比率の目安**:
- 単体テスト: 70%
- 統合テスト: 20%
- E2Eテスト: 10%

### テストファースト

可能な限り、テストを先に書く（TDD）。

```
1. テストを書く（失敗することを確認）
2. 最小限の実装で通す
3. リファクタリング
```

## パフォーマンステスト

### 応答時間

```typescript
test('getUser は100ms以内に応答する', async () => {
  const start = Date.now()
  await getUser('user-123')
  const duration = Date.now() - start

  expect(duration).toBeLessThan(100)
})
```

### 負荷テスト

```typescript
test('1000リクエストを同時処理できる', async () => {
  const requests = Array(1000).fill(null).map(() => getUser('user-123'))
  const results = await Promise.all(requests)

  expect(results).toHaveLength(1000)
  expect(results.every(r => r !== null)).toBe(true)
})
```

## スナップショットテスト

UI コンポーネントなどに使用。

```typescript
test('ユーザーカードが正しくレンダリングされる', () => {
  const { container } = render(<UserCard user={testUser} />)
  expect(container).toMatchSnapshot()
})
```

⚠️ スナップショットテストは補助的に使用し、ロジックのテストを優先する。

## テストの保守

### 壊れやすいテストを避ける

❌ 悪い例（実装詳細に依存）:
```typescript
test('内部メソッドが呼ばれる', () => {
  const spy = jest.spyOn(service, '_internalMethod')
  service.publicMethod()
  expect(spy).toHaveBeenCalled()
})
```

✅ 良い例（公開インターフェースをテスト）:
```typescript
test('ユーザーを作成できる', () => {
  const user = service.createUser({ name: 'Alice' })
  expect(user.name).toBe('Alice')
})
```

### テストの重複を避ける

共通処理はヘルパー関数に抽出。

```typescript
// test/helpers/setup-database.ts
export const setupTestDatabase = async () => {
  await database.migrate()
  await database.seed()
}

export const cleanupTestDatabase = async () => {
  await database.truncate()
}
```

## チェックリスト

### 新機能実装時
- [ ] 単体テストを作成
- [ ] 統合テストを作成（必要に応じて）
- [ ] E2Eテストを作成（主要フローの場合）
- [ ] カバレッジ80%以上を達成
- [ ] すべてのエッジケースをテスト

### バグ修正時
- [ ] バグを再現するテストを作成
- [ ] テストが失敗することを確認
- [ ] バグを修正
- [ ] テストが成功することを確認

### リファクタリング時
- [ ] 既存のテストが成功することを確認
- [ ] カバレッジが低下していないことを確認

### レビュー時
- [ ] テストが適切に書かれている
- [ ] テスト名が明確
- [ ] エッジケースがカバーされている
- [ ] カバレッジが基準を満たしている
