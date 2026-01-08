# Python コーディング規約

## 概要

Python プロジェクトのコーディング規約です。
基本的に PEP 8 に従います。

## 基本設定

### Python バージョン
Python 3.10 以上を使用します。

### フォーマッタ
Black を使用します。

```bash
pip install black
black .
```

### リンター
ruff を使用します。

```bash
pip install ruff
ruff check .
```

### 型チェック
mypy を使用します。

```bash
pip install mypy
mypy .
```

## 命名規則

### 変数・関数
snake_case を使用します。

```python
user_name = "Alice"
is_active = True

def get_user_by_id(user_id: str) -> User | None:
    pass
```

### クラス
PascalCase を使用します。

```python
class UserService:
    pass

class ValidationError(Exception):
    pass
```

### 定数
UPPER_SNAKE_CASE を使用します。

```python
MAX_RETRY_COUNT = 3
API_BASE_URL = "https://api.example.com"
```

### プライベート
アンダースコアで始めます。

```python
class User:
    def __init__(self):
        self._password = None  # プライベート属性

    def _hash_password(self):  # プライベートメソッド
        pass
```

### ファイル名
snake_case を使用します。

```
user_service.py
auth_middleware.py
```

## 型ヒント

### 必須
すべての関数に型ヒントを付けます。

```python
# ❌ 型ヒントなし
def get_user(user_id):
    return db.users.find(user_id)

# ✅ 型ヒント付き
def get_user(user_id: str) -> User | None:
    return db.users.find(user_id)
```

### typing モジュール
```python
from typing import List, Dict, Optional, Union, Any

def process_users(users: List[User]) -> Dict[str, int]:
    return {user.id: user.age for user in users}

# Python 3.10+: 組み込み型を直接使用可能
def process_users(users: list[User]) -> dict[str, int]:
    return {user.id: user.age for user in users}
```

### Optional と None
Python 3.10+ では `|` を使用します。

```python
# Python 3.9 以前
from typing import Optional
def get_user(user_id: str) -> Optional[User]:
    pass

# Python 3.10+
def get_user(user_id: str) -> User | None:
    pass
```

## 関数

### 小さく保つ
1関数は20行程度を目安にします。

```python
# ✅ 単一責任
def validate_email(email: str) -> bool:
    """メールアドレスのバリデーション"""
    return "@" in email and "." in email.split("@")[1]

def create_user(email: str, name: str) -> User:
    """ユーザー作成"""
    if not validate_email(email):
        raise ValidationError("Invalid email")
    return User(email=email, name=name)
```

### デフォルト引数
mutable なオブジェクトをデフォルト引数にしない。

```python
# ❌ mutable なデフォルト引数
def add_item(item: str, items: list = []):
    items.append(item)
    return items

# ✅ None を使用
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### Docstring
すべての公開関数にdocstringを記載します。

```python
def get_user(user_id: str) -> User | None:
    """
    ユーザーIDからユーザー情報を取得します

    Args:
        user_id: ユーザーID

    Returns:
        ユーザー情報。見つからない場合は None

    Raises:
        DatabaseError: データベース接続に失敗した場合
    """
    return db.users.find(user_id)
```

## クラス

### データクラス
データを保持するだけのクラスは dataclass を使用します。

```python
from dataclasses import dataclass

@dataclass
class User:
    id: str
    name: str
    email: str
    age: int = 0  # デフォルト値
```

### プロパティ
getter/setter の代わりに property を使用します。

```python
class User:
    def __init__(self, name: str):
        self._name = name

    @property
    def name(self) -> str:
        return self._name

    @name.setter
    def name(self, value: str) -> None:
        if not value:
            raise ValueError("Name cannot be empty")
        self._name = value
```

### コンテキストマネージャ
リソース管理には `with` を使用します。

```python
# ✅ コンテキストマネージャ
with open("file.txt", "r") as f:
    content = f.read()

# ✅ カスタムコンテキストマネージャ
from contextlib import contextmanager

@contextmanager
def database_transaction():
    """データベーストランザクション"""
    try:
        db.begin()
        yield
        db.commit()
    except Exception:
        db.rollback()
        raise

# 使用例
with database_transaction():
    db.users.create(user)
```

## エラーハンドリング

### カスタム例外
```python
class ValidationError(Exception):
    """バリデーションエラー"""
    def __init__(self, message: str, field: str):
        super().__init__(message)
        self.field = field

# 使用例
if not email:
    raise ValidationError("Email is required", field="email")
```

### 例外の補足
```python
# ✅ 具体的な例外を補足
try:
    user = get_user(user_id)
except ValueError as e:
    logger.error(f"Invalid user ID: {e}")
    raise
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise

# ❌ すべての例外を補足
try:
    user = get_user(user_id)
except:  # bare except は避ける
    pass
```

## リスト・辞書操作

### リスト内包表記
```python
# ✅ リスト内包表記
names = [user.name for user in users]

# ✅ フィルタ付き
active_users = [user for user in users if user.is_active]

# ✅ 辞書内包表記
user_map = {user.id: user.name for user in users}
```

### ジェネレータ式
大きなデータセットにはジェネレータを使用します。

```python
# ✅ ジェネレータ
total = sum(user.age for user in users)

# ✅ ジェネレータ関数
def read_large_file(file_path: str):
    """大きなファイルを1行ずつ読み込む"""
    with open(file_path) as f:
        for line in f:
            yield line.strip()
```

## 文字列

### f-string を優先
```python
name = "Alice"
age = 30

# ❌ % フォーマット
message = "Name: %s, Age: %d" % (name, age)

# ❌ .format()
message = "Name: {}, Age: {}".format(name, age)

# ✅ f-string
message = f"Name: {name}, Age: {age}"
```

## インポート

### 順序
```python
# 1. 標準ライブラリ
import os
import sys
from datetime import datetime

# 2. サードパーティライブラリ
import requests
from fastapi import FastAPI

# 3. ローカルモジュール
from app.models import User
from app.services import UserService
```

### 絶対インポート優先
```python
# ✅ 絶対インポート
from app.services.user_service import UserService

# ❌ 相対インポート（避ける）
from ..services.user_service import UserService
```

## 非同期処理

### async/await
```python
async def fetch_user(user_id: str) -> User:
    """非同期でユーザーを取得"""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"/api/users/{user_id}")
        return response.json()

# 複数の非同期処理を並行実行
import asyncio

async def fetch_multiple_users(user_ids: list[str]) -> list[User]:
    """複数ユーザーを並行取得"""
    tasks = [fetch_user(user_id) for user_id in user_ids]
    return await asyncio.gather(*tasks)
```

## テスト

### テストファイル名
```
user_service.py       → test_user_service.py
auth_middleware.py    → test_auth_middleware.py
```

### pytest を使用
```python
import pytest
from app.services import UserService

class TestUserService:
    """UserService のテスト"""

    def test_find_by_id_existing_user(self):
        """存在するユーザーを取得できる"""
        user = UserService.find_by_id("user-123")
        assert user is not None
        assert user.id == "user-123"

    def test_find_by_id_not_found(self):
        """存在しないユーザーの場合は None を返す"""
        user = UserService.find_by_id("not-found")
        assert user is None

    def test_create_user_invalid_email(self):
        """無効なメールアドレスでエラーが発生する"""
        with pytest.raises(ValidationError) as exc_info:
            UserService.create(email="invalid", name="Alice")
        assert exc_info.value.field == "email"
```

### フィクスチャ
```python
@pytest.fixture
def sample_user() -> User:
    """テスト用ユーザー"""
    return User(id="user-123", name="Alice", email="alice@example.com")

def test_update_user(sample_user: User):
    """ユーザー更新のテスト"""
    updated = UserService.update(sample_user.id, name="Bob")
    assert updated.name == "Bob"
```

## ロギング

### logging モジュール
```python
import logging

logger = logging.getLogger(__name__)

def process_user(user: User) -> None:
    """ユーザー処理"""
    logger.info(f"Processing user: {user.id}")
    try:
        # 処理
        logger.debug(f"User processed successfully: {user.id}")
    except Exception as e:
        logger.error(f"Failed to process user: {user.id}", exc_info=True)
        raise
```

## その他

### enumerate を活用
```python
# ✅ enumerate
for index, item in enumerate(items):
    print(f"{index}: {item}")

# ❌ 手動でカウント
index = 0
for item in items:
    print(f"{index}: {item}")
    index += 1
```

### zip を活用
```python
names = ["Alice", "Bob"]
ages = [30, 25]

# ✅ zip
for name, age in zip(names, ages):
    print(f"{name}: {age}")
```

### パス操作
```python
from pathlib import Path

# ✅ pathlib
config_path = Path(__file__).parent / "config.yaml"
if config_path.exists():
    content = config_path.read_text()

# ❌ os.path
import os
config_path = os.path.join(os.path.dirname(__file__), "config.yaml")
```

## チェックリスト

- [ ] すべての関数に型ヒントを付与
- [ ] 公開関数に docstring を記載
- [ ] Black でフォーマット
- [ ] ruff でリント
- [ ] mypy で型チェック
- [ ] テストを作成
- [ ] PEP 8 に準拠
