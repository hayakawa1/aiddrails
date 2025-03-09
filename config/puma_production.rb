# Pumaの設定ファイル

# アプリケーションのディレクトリ
app_dir = File.expand_path("../..", __FILE__)
directory app_dir

# 環境変数の設定
environment "production"

# ソケットファイル
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

# スレッド数
threads 5, 5

# ログ設定
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

# プロセス管理
pidfile "#{app_dir}/tmp/pids/puma.pid" 