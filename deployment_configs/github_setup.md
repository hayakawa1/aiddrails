# GitHub Actions デプロイ設定ガイド

このガイドでは、GitHub Actionsを使用して自動デプロイを設定する方法について説明します。

## 必要なシークレットの設定

GitHubリポジトリの「Settings」→「Secrets and variables」→「Actions」で以下のシークレットを追加する必要があります：

### 1. SSH_PRIVATE_KEY

デプロイ用のSSH秘密鍵です。以下のコマンドで内容を確認できます：

```bash
cat ~/.ssh/aidd_deploy
```

この出力全体（`-----BEGIN OPENSSH PRIVATE KEY-----`から`-----END OPENSSH PRIVATE KEY-----`まで）をコピーして、GitHubのシークレットとして保存します。

### 2. KNOWN_HOSTS

サーバーのSSHホスト鍵情報です。以下のコマンドで取得できます：

```bash
ssh-keyscan -H 45.76.194.174
```

この出力全体をコピーして、GitHubのシークレットとして保存します。

### 3. RAILS_MASTER_KEY

Railsアプリケーションのマスターキーです。以下のコマンドで内容を確認できます：

```bash
cat config/master.key
```

この出力をコピーして、GitHubのシークレットとして保存します。

### 4. PRODUCTION_KEY (オプション)

本番環境用の追加キーがある場合は、以下のコマンドで内容を確認できます：

```bash
cat config/credentials/production.key
```

この出力をコピーして、GitHubのシークレットとして保存します。

## 手動デプロイのトリガー方法

1. GitHubリポジトリの「Actions」タブに移動します
2. 左側のサイドバーから「Deploy to Production」ワークフローを選択します
3. 右側の「Run workflow」ボタンをクリックします
4. 「Branch: main」を選択して「Run workflow」をクリックします

## トラブルシューティング

### デプロイが失敗する場合

1. GitHub Actionsのログを確認して、エラーメッセージを特定します
2. 以下の一般的な問題を確認します：
   - SSH接続の問題：SSH_PRIVATE_KEYとKNOWN_HOSTSが正しく設定されているか確認
   - 認証情報の問題：RAILS_MASTER_KEYとPRODUCTION_KEYが正しく設定されているか確認
   - サーバー上の権限問題：デプロイディレクトリの権限を確認

### サーバー上での確認

サーバーにSSH接続して以下のコマンドを実行することで、デプロイ状況を確認できます：

```bash
# デプロイディレクトリの確認
ls -la /var/www/aidd/myapp

# 最新のデプロイログの確認
tail -f /var/www/aidd/myapp/current/log/production.log

# Pumaサーバーのステータス確認
systemctl status puma
```

## セキュリティに関する注意事項

- SSH鍵は安全に保管し、不要になったら削除してください
- GitHubのシークレットは定期的に更新することをお勧めします
- 本番環境では、rootユーザーではなく専用のデプロイユーザーを使用することを検討してください
