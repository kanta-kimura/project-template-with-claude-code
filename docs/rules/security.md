# セキュリティガイドライン

プロジェクトにおけるセキュリティのベストプラクティスとチェックリストです。

## 基本原則

1. **多層防御**: 複数のセキュリティ層を実装
2. **最小権限の原則**: 必要最小限の権限のみを付与
3. **デフォルトで安全**: 安全な設定をデフォルトにする
4. **入力を信用しない**: すべての入力を検証
5. **機密情報の保護**: パスワード・トークンを適切に管理

## OWASP Top 10 対策

### 1. インジェクション

#### SQLインジェクション

❌ 危険:
```typescript
// SQL文字列の直接結合
const query = `SELECT * FROM users WHERE email = '${email}'`
db.query(query)
```

✅ 安全:
```typescript
// プリペアドステートメント
const query = 'SELECT * FROM users WHERE email = ?'
db.query(query, [email])

// ORMの使用
User.findOne({ where: { email } })
```

#### コマンドインジェクション

❌ 危険:
```typescript
exec(`ping ${userInput}`)
```

✅ 安全:
```typescript
// 入力を検証
const validatedInput = validator.isIP(userInput) ? userInput : null
if (!validatedInput) throw new Error('Invalid IP')

// または専用ライブラリを使用
const ping = require('ping')
ping.promise.probe(userInput)
```

### 2. 認証の不備

#### パスワード管理

❌ 危険:
```typescript
// 平文保存
user.password = password

// 弱いハッシュ（MD5, SHA1）
user.password = md5(password)
```

✅ 安全:
```typescript
// bcrypt または argon2 を使用
import bcrypt from 'bcrypt'

const hashedPassword = await bcrypt.hash(password, 10)

// 検証
const isValid = await bcrypt.compare(password, hashedPassword)
```

#### セッション管理

✅ 安全な設定:
```typescript
app.use(session({
  secret: process.env.SESSION_SECRET, // 長いランダム文字列
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,      // HTTPS のみ
    httpOnly: true,    // JavaScript からアクセス不可
    maxAge: 3600000,   // 1時間
    sameSite: 'strict' // CSRF 対策
  }
}))
```

#### JWT トークン

✅ 安全な実装:
```typescript
import jwt from 'jsonwebtoken'

// トークン生成
const token = jwt.sign(
  { userId: user.id },
  process.env.JWT_SECRET,
  { expiresIn: '1h' }
)

// トークン検証
try {
  const decoded = jwt.verify(token, process.env.JWT_SECRET)
} catch (error) {
  throw new Error('Invalid token')
}
```

### 3. 機密データの露出

#### 環境変数

❌ 危険:
```typescript
const API_KEY = 'sk-1234567890abcdef' // ハードコード
```

✅ 安全:
```typescript
const API_KEY = process.env.API_KEY
if (!API_KEY) {
  throw new Error('API_KEY not configured')
}
```

#### ログ出力

❌ 危険:
```typescript
logger.info(`User logged in: ${JSON.stringify(user)}`)
// パスワード、トークンなどが含まれる可能性
```

✅ 安全:
```typescript
logger.info(`User logged in: ${user.id}`)

// または機密情報を除外
const safeUser = {
  id: user.id,
  email: user.email
  // password, token などは含めない
}
logger.info(`User logged in: ${JSON.stringify(safeUser)}`)
```

#### エラーメッセージ

❌ 危険:
```typescript
// 詳細なエラーをクライアントに返す
res.status(500).json({
  error: error.stack,
  query: sqlQuery,
  credentials: dbConfig
})
```

✅ 安全:
```typescript
// 一般的なエラーメッセージ
res.status(500).json({
  error: 'Internal server error'
})

// 詳細はサーバーログにのみ記録
logger.error('Database error', { error, query })
```

### 4. XML外部実体参照（XXE）

✅ 安全な XML パーサー設定:
```typescript
import xml2js from 'xml2js'

const parser = new xml2js.Parser({
  // 外部エンティティを無効化
  explicitCharkey: false,
  trim: true,
  normalize: true,
  normalizeTags: true,
  mergeAttrs: true
})
```

### 5. アクセス制御の不備

#### 認可チェック

❌ 危険:
```typescript
// ユーザーIDをクライアントから受け取る
app.delete('/user/:id', (req, res) => {
  deleteUser(req.params.id) // 他人のアカウントを削除できる
})
```

✅ 安全:
```typescript
app.delete('/user/:id', requireAuth, (req, res) => {
  // 認証済みユーザー自身または管理者のみ
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' })
  }
  deleteUser(req.params.id)
})
```

#### パスト ラバーサル

❌ 危険:
```typescript
// ユーザー入力をそのままファイルパスに使用
const content = fs.readFileSync(`/uploads/${req.params.filename}`)
// ../../../etc/passwd のようなパスが指定される可能性
```

✅ 安全:
```typescript
import path from 'path'

// パスを正規化してベースディレクトリ外を防ぐ
const filename = path.basename(req.params.filename)
const filepath = path.join('/uploads', filename)

// さらに検証
if (!filepath.startsWith('/uploads/')) {
  throw new Error('Invalid path')
}

const content = fs.readFileSync(filepath)
```

### 6. セキュリティ設定のミス

#### HTTP ヘッダー

✅ 安全なヘッダー設定:
```typescript
import helmet from 'helmet'

app.use(helmet()) // 基本的なセキュリティヘッダーを自動設定

// または個別に設定
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff')
  res.setHeader('X-Frame-Options', 'DENY')
  res.setHeader('X-XSS-Protection', '1; mode=block')
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
  next()
})
```

#### CORS

✅ 適切な CORS 設定:
```typescript
import cors from 'cors'

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'https://example.com',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}))
```

### 7. XSS (クロスサイトスクリプティング)

#### 出力のエスケープ

❌ 危険:
```html
<!-- ユーザー入力をそのまま表示 -->
<div>{userInput}</div>
```

✅ 安全:
```typescript
// React: 自動でエスケープされる
<div>{userInput}</div>

// Vue: 自動でエスケープされる
<div>{{ userInput }}</div>

// 素のHTML: エスケープ関数を使用
import escape from 'escape-html'
const html = `<div>${escape(userInput)}</div>`
```

#### Content Security Policy

✅ CSP ヘッダーの設定:
```typescript
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
  )
  next()
})
```

### 8. 安全でないデシリアライゼーション

❌ 危険:
```typescript
// eval の使用
eval(userInput)

// 信頼できないデータのデシリアライズ
const obj = JSON.parse(userInput)
new Function(obj.code)()
```

✅ 安全:
```typescript
// JSON のみ許可
const obj = JSON.parse(userInput)

// スキーマ検証
import { z } from 'zod'

const schema = z.object({
  name: z.string(),
  age: z.number().positive()
})

const validated = schema.parse(obj)
```

### 9. 既知の脆弱性を持つコンポーネント

#### 依存関係の管理

```bash
# 脆弱性チェック
npm audit

# 自動修正
npm audit fix

# または
yarn audit
```

#### 定期的な更新

```bash
# 依存関係を最新に更新
npm update

# メジャーバージョンアップ
npx npm-check-updates -u
npm install
```

### 10. ログとモニタリングの不足

#### ログ記録

✅ 記録すべきイベント:
```typescript
// 認証イベント
logger.info('User logged in', { userId, ip: req.ip, timestamp })
logger.warn('Failed login attempt', { email, ip: req.ip })

// セキュリティイベント
logger.warn('Unauthorized access attempt', { userId, resource, ip: req.ip })

// エラー
logger.error('Database error', { error, userId, operation })
```

❌ 記録してはいけない情報:
- パスワード
- トークン
- クレジットカード情報
- 個人情報（必要最小限のみ）

## 入力検証

### バリデーションライブラリの使用

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  age: z.number().int().positive().max(150)
})

// バリデーション
try {
  const validated = userSchema.parse(userInput)
} catch (error) {
  return res.status(400).json({ error: 'Invalid input' })
}
```

### サニタイゼーション

```typescript
import validator from 'validator'

// HTML タグを除去
const clean = validator.escape(userInput)

// URL の検証
if (!validator.isURL(url)) {
  throw new Error('Invalid URL')
}
```

## レート制限

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分
  max: 100, // 最大100リクエスト
  message: 'Too many requests'
})

app.use('/api/', limiter)

// ログイン用の厳しい制限
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true
})

app.post('/login', loginLimiter, loginHandler)
```

## CSRF 対策

```typescript
import csrf from 'csurf'

const csrfProtection = csrf({ cookie: true })

app.use(csrfProtection)

app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() })
})

app.post('/submit', (req, res) => {
  // CSRF トークンが自動検証される
  res.send('Data saved')
})
```

## セキュリティチェックリスト

### 実装時
- [ ] すべての入力を検証
- [ ] 出力をエスケープ
- [ ] SQL インジェクション対策
- [ ] XSS 対策
- [ ] CSRF 対策
- [ ] 認証・認可を実装
- [ ] パスワードをハッシュ化
- [ ] 機密情報をハードコードしない

### デプロイ前
- [ ] HTTPS を有効化
- [ ] セキュリティヘッダーを設定
- [ ] 環境変数を設定
- [ ] デフォルトパスワードを変更
- [ ] 不要なエンドポイントを削除
- [ ] エラーメッセージを一般化
- [ ] ログ設定を確認
- [ ] 依存関係の脆弱性をチェック

### 定期的に
- [ ] 依存関係を更新
- [ ] セキュリティログを確認
- [ ] アクセス権限を見直し
- [ ] パスワードポリシーを見直し
- [ ] バックアップを確認

## インシデント対応

### 脆弱性発見時

1. **記録**: 詳細を記録
2. **評価**: 影響範囲を評価
3. **修正**: 緊急度に応じて修正
4. **通知**: 必要に応じてユーザーに通知
5. **事後分析**: 再発防止策を検討

### セキュリティインシデント

1. **検知**: ログ・モニタリングで検知
2. **隔離**: 影響を最小限に抑える
3. **調査**: 原因を特定
4. **復旧**: システムを復旧
5. **報告**: 関係者に報告
6. **改善**: 対策を実施

## 参考資料

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [セキュアコーディングガイド](https://www.ipa.go.jp/security/vuln/websecurity.html)
