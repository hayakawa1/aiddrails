# Pumaの設定ファイル

# アプリケーションのディレクトリ
app_dir = File.expand_path("../..", __FILE__)
directory app_dir

# 環境変数の設定
environment ENV.fetch("RAILS_ENV") { "production" }

# PIDファイル
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

# SSL設定
ssl_bind '0.0.0.0', '443', {
  key: "/etc/letsencrypt/live/aidd.work/privkey.pem",
  cert: "/etc/letsencrypt/live/aidd.work/fullchain.pem",
  verify_mode: 'none'
}

# ソケットファイル
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

# ポート番号
port ENV.fetch("PORT") { 3000 }

# スレッド数とワーカー数
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# 標準出力とエラー出力のリダイレクト
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

# プラグインの設定
plugin :tmp_restart 