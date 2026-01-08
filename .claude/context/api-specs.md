# API仕様

全インスタンスで共有するAPI仕様を記載します。

## 概要

このドキュメントはプロジェクト内で使用するAPIの仕様を定義します。
実装時にはこの仕様に従ってください。

---

## 共通仕様

### ベースURL
```
開発環境: http://localhost:3000/api
本番環境: https://api.example.com
```

### 認証
すべてのAPI（ログイン・登録を除く）はJWTトークンによる認証が必要です。

```http
Authorization: Bearer <JWT_TOKEN>
```

### レスポンス形式

#### 成功レスポンス
```json
{
  "success": true,
  "data": {
    // レスポンスデータ
  }
}
```

#### エラーレスポンス
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ",
    "details": {} // オプション
  }
}
```

### HTTPステータスコード
- `200 OK`: 成功
- `201 Created`: リソース作成成功
- `400 Bad Request`: リクエストが不正
- `401 Unauthorized`: 認証が必要
- `403 Forbidden`: 権限なし
- `404 Not Found`: リソースが存在しない
- `500 Internal Server Error`: サーバーエラー

### ページネーション
リスト取得APIは以下のクエリパラメータをサポートします。

```
?page=1&limit=20
```

レスポンス:
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

---

## エンドポイント一覧

### 認証

#### POST /auth/register
ユーザー登録

**リクエスト:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "name": "山田太郎"
}
```

**レスポンス:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "山田太郎"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### POST /auth/login
ログイン

**リクエスト:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**レスポンス:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "山田太郎"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## 実装時の注意事項

### バリデーション
すべての入力は適切にバリデーションしてください。

### エラーコード
エラーコードは以下の命名規則に従います:
```
[カテゴリ]_[詳細]

例:
- AUTH_INVALID_TOKEN
- VALIDATION_REQUIRED_FIELD
- USER_NOT_FOUND
```

### ログ
すべてのAPIリクエストをログに記録してください:
- リクエストメソッド・パス
- レスポンスステータス
- 処理時間
- エラー発生時は詳細情報

---

## 更新履歴

このセクションにAPI仕様の変更履歴を記録してください。

| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2025-01-08 | 初版作成 | - |
