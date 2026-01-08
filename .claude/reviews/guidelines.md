# レビューガイドライン

このドキュメントはコードレビューの具体的な観点とチェックポイントをまとめたものです。
詳細なプロセスは `.claude/workflows/review-process.md` を参照してください。

## レビューの目的

1. **品質保証**: バグや問題の早期発見
2. **知識共有**: 実装パターンやベストプラクティスの共有
3. **一貫性の維持**: コードベース全体の統一性を保つ
4. **学習機会**: より良い実装方法を学ぶ

## 重点チェックポイント

### 🔒 セキュリティ（最優先）

#### 入力検証
```typescript
// ❌ 悪い例
app.post('/user', (req, res) => {
  const { name, email } = req.body
  db.query(`INSERT INTO users VALUES ('${name}', '${email}')`)
})

// ✅ 良い例
app.post('/user', (req, res) => {
  const schema = z.object({
    name: z.string().max(100),
    email: z.string().email()
  })
  const validated = schema.parse(req.body)
  db.query('INSERT INTO users VALUES (?, ?)', [validated.name, validated.email])
})
```

#### 認証・認可
```typescript
// ❌ 悪い例
app.delete('/user/:id', (req, res) => {
  db.query('DELETE FROM users WHERE id = ?', [req.params.id])
})

// ✅ 良い例
app.delete('/user/:id', requireAuth, (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' })
  }
  db.query('DELETE FROM users WHERE id = ?', [req.params.id])
})
```

#### 機密情報
```typescript
// ❌ 悪い例
const API_KEY = 'sk-1234567890abcdef'

// ✅ 良い例
const API_KEY = process.env.API_KEY
if (!API_KEY) throw new Error('API_KEY not configured')
```

### 🐛 バグの可能性

#### Null/Undefined チェック
```typescript
// ❌ 悪い例
const userName = user.profile.name.toUpperCase()

// ✅ 良い例
const userName = user?.profile?.name?.toUpperCase() ?? 'Anonymous'
```

#### エラーハンドリング
```typescript
// ❌ 悪い例
async function fetchData() {
  const response = await fetch('/api/data')
  return response.json()
}

// ✅ 良い例
async function fetchData() {
  try {
    const response = await fetch('/api/data')
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return await response.json()
  } catch (error) {
    logger.error('Failed to fetch data', error)
    throw error
  }
}
```

### ⚡ パフォーマンス

#### N+1 問題
```typescript
// ❌ 悪い例
const users = await db.query('SELECT * FROM users')
for (const user of users) {
  user.posts = await db.query('SELECT * FROM posts WHERE user_id = ?', [user.id])
}

// ✅ 良い例
const users = await db.query('SELECT * FROM users')
const userIds = users.map(u => u.id)
const posts = await db.query('SELECT * FROM posts WHERE user_id IN (?)', [userIds])
const postsByUser = groupBy(posts, 'user_id')
users.forEach(user => {
  user.posts = postsByUser[user.id] || []
})
```

#### 不要な計算
```typescript
// ❌ 悪い例
function render() {
  const total = items.reduce((sum, item) => sum + item.price, 0)
  return <div>Total: {total}</div>
}

// ✅ 良い例 (React)
function render() {
  const total = useMemo(
    () => items.reduce((sum, item) => sum + item.price, 0),
    [items]
  )
  return <div>Total: {total}</div>
}
```

### 📝 コードの可読性

#### 命名
```typescript
// ❌ 悪い例
const d = new Date()
const temp = data.filter(x => x.a > 10)

// ✅ 良い例
const currentDate = new Date()
const activeUsers = users.filter(user => user.loginCount > 10)
```

#### 関数の責任
```typescript
// ❌ 悪い例
function processUser(user) {
  // ユーザー検証
  if (!user.email) throw new Error('Invalid email')
  // データベース更新
  db.update('users', user)
  // メール送信
  sendEmail(user.email, 'Welcome!')
  // ログ記録
  logger.info(`User ${user.id} processed`)
}

// ✅ 良い例
function validateUser(user) {
  if (!user.email) throw new Error('Invalid email')
}

function processUser(user) {
  validateUser(user)
  updateUserInDatabase(user)
  sendWelcomeEmail(user)
  logUserProcessed(user)
}
```

### 🧪 テスト

#### テストカバレッジ
```typescript
// ❌ 不十分
test('adds numbers', () => {
  expect(add(2, 3)).toBe(5)
})

// ✅ 良い
describe('add', () => {
  test('正の数の加算', () => {
    expect(add(2, 3)).toBe(5)
  })

  test('負の数の加算', () => {
    expect(add(-2, 3)).toBe(1)
  })

  test('ゼロの加算', () => {
    expect(add(0, 5)).toBe(5)
  })

  test('小数点の加算', () => {
    expect(add(0.1, 0.2)).toBeCloseTo(0.3)
  })
})
```

## 言語別チェックポイント

### TypeScript
- [ ] 型定義が適切（`any` を避ける）
- [ ] Optional chaining の活用
- [ ] Null安全性の確保
- [ ] 適切なジェネリクスの使用

### Python
- [ ] Type hints の使用
- [ ] PEP 8 準拠
- [ ] コンテキストマネージャの使用（`with`）
- [ ] リスト内包表記の適切な使用

### Go
- [ ] エラーハンドリングが適切
- [ ] defer の適切な使用
- [ ] goroutine のリークがない
- [ ] 適切な並行制御

## レビューコメントのテンプレート

### セキュリティ問題
```
🔒 セキュリティ: [問題の説明]

この実装は [脆弱性の種類] の危険性があります。

推奨: [修正方法]

参考: [関連ドキュメントへのリンク]
```

### パフォーマンス改善
```
⚡ パフォーマンス: [問題の説明]

現在の実装は O(n²) の計算量です。

推奨: [改善方法]

期待される改善: O(n) に削減
```

### バグの可能性
```
🐛 潜在的なバグ: [問題の説明]

[どのような状況で問題が起きるか]

推奨: [修正方法]
```

### 可読性の改善
```
📝 可読性: [問題の説明]

[なぜ分かりにくいか]

推奨: [改善方法]
```

## レビューの優先度

### P0 (ブロッカー) - 修正必須
- セキュリティ脆弱性
- データ損失のリスク
- クリティカルなバグ
- 仕様との明確な不一致

### P1 (重要) - 修正推奨
- パフォーマンス問題
- エラーハンドリングの不足
- テストカバレッジ不足
- 保守性の問題

### P2 (軽微) - 任意
- コードスタイル
- 命名の改善提案
- コメントの追加
- リファクタリング提案

## 良いレビューの例

```markdown
## 全体的な評価
ユーザー認証機能の実装、お疲れ様です。
全体的に仕様通りに実装されており、テストカバレッジも十分です。

## ✅ 良い点
- JWT トークンの実装が適切
- エラーハンドリングが丁寧
- テストケースが充実している

## 🔒 P0: セキュリティ
**src/auth/login.ts:45**

パスワードのハッシュ化にMD5が使用されていますが、MD5は安全ではありません。

推奨:
bcrypt または argon2 を使用してください。

```typescript
import bcrypt from 'bcrypt'

const hashedPassword = await bcrypt.hash(password, 10)
```

## ⚡ P1: パフォーマンス
**src/auth/session.ts:78**

セッション検証のたびにデータベースクエリが発生しています。
Redis などのキャッシュを検討してください。

## 📝 P2: 可読性
**src/auth/middleware.ts:23**

変数名 `t` は分かりにくいため、`token` に変更を推奨します。

## 次のアクション
1. パスワードハッシュ化の修正（P0）
2. セッションキャッシュの検討（P1）
```

## 避けるべきレビュー

### ❌ 悪い例
```
このコードは良くないです。書き直してください。
```

### ❌ 悪い例
```
私ならこうは書きません。
```

### ❌ 悪い例
```
なんでこんな実装にしたんですか？
```

## まとめ

- 建設的で具体的なフィードバックを心がける
- 優先度を明確にする
- 良い点も積極的に評価する
- 学習機会として活用する
