# AIDD.WORK デプロイ手順

## デプロイ設定

### 前提条件
- Ruby 3.2.7
- Rails 8.0.1
- PostgreSQL 14
- Nginx 1.18.0
- Puma 5.6.9

### デプロイ手順

#### 1. 初回デプロイ準備

```bash
# サーバー上で共有ディレクトリを作成
cap production deploy:check

# 必要なファイルをアップロード
# config/database.yml, config/master.key, config/credentials/production.key など
```

#### 2. デプロイ実行

```bash
# デプロイ実行
cap production deploy

# アセットのプリコンパイル
cap production deploy:assets:precompile

# データベースマイグレーション
cap production deploy:migrate
```

#### 3. Pumaの再起動

```bash
cap production puma:restart
```

### 運用コマンド

#### ログの確認

```bash
# Railsのログを確認
cap production logs:tail

# Pumaのログを確認
cap production logs:puma

# Nginxのログを確認
cap production logs:nginx

# Systemdのログを確認
cap production logs:systemd
```

#### データベースバックアップ

```bash
# データベースのバックアップを作成
cap production db:backup

# 最新のバックアップをダウンロード
cap production db:download
```

### サーバー情報

- サーバーIP: 45.76.194.174
- ユーザー: root
- デプロイディレクトリ: /var/www/aidd/myapp

### 注意事項

1. **セキュリティ**
   - 現在rootユーザーを使用していますが、本番環境では専用のデプロイユーザーを作成することを推奨します
   - SSHキー認証を設定することを推奨します

2. **バックアップ**
   - 定期的なデータベースバックアップを設定してください
   - `crontab -e` で以下のように設定することを推奨します:
     ```
     0 3 * * * cd /var/www/aidd/myapp/current && RAILS_ENV=production bundle exec rake db:backup
     ```

3. **モニタリング**
   - アプリケーションのパフォーマンスを監視するために、New Relic や Datadog などのモニタリングツールの導入を検討してください

4. **スケーリング**
   - トラフィックが増加した場合は、Pumaのワーカー数とスレッド数を調整してください
   - `config/deploy.rb` の `puma_workers` と `puma_threads` を調整します
