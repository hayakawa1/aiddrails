# プロジェクトのクリーンアップ指示

以下のファイル/ディレクトリは不要なため、削除することをお勧めします。

## システム関連の不要ファイル

1. `.DS_Store` - Macのシステムファイル
   ```bash
   find . -name ".DS_Store" -delete
   ```

2. `tmp/` - 一時ファイルディレクトリ（継続的に生成されるので、.gitignoreに含めるべき）
   ```bash
   rm -rf tmp/*
   ```

3. `.ssh/` - SSHディレクトリ（アプリケーションとは直接関係ない）
   ```bash
   rm -rf .ssh
   ```

## 開発関連の不要ファイル

1. `node_modules/` - npmパッケージ（.gitignoreに含めるべき）
   ```bash
   echo "node_modules/" >> .gitignore
   ```

2. `specification.md` - 現在の仕様書（`current_specifications.md`）と重複
   ```bash
   # 新しく作成した docs/current_system_specifications.md に置き換え済み
   mv specification.md docs/old_specification.md  # 念のため移動
   ```

## .gitignoreの更新

`.gitignore`ファイルに以下の項目が含まれていることを確認し、必要に応じて追加してください：

```
# 一時ファイル
/tmp/*
!/tmp/.keep

# ログファイル
/log/*
!/log/.keep

# 依存関係ディレクトリ
/node_modules

# MacOSシステムファイル
.DS_Store

# 環境変数ファイル
.env
```

## 不要なgemの整理

使用していないgemがあれば、Gemfileから削除して`bundle install`を実行してください。

## 継続的なメンテナンス

アプリケーションを継続的にクリーンに保つために以下を実施してください：

1. 使用されていないモデル、コントローラー、ビューの削除
2. テストカバレッジの確保と不要なテストの削除
3. 古いマイグレーションファイルの整理（必要に応じて）
4. ログファイルの定期的なローテーション 