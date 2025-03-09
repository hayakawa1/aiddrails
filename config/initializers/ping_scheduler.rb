require 'rufus-scheduler'
require 'net/http'

# 本番環境でのみスケジューラーを実行（開発環境では完全に無効化）
if Rails.env.production? && !Rails.env.test? && !Rails.env.development?
  scheduler = Rufus::Scheduler.new

  # アプリケーションのURLを設定
  app_url = ENV['APP_URL'] || 'https://your-app-url.onrender.com'
  
  # 14分ごとにアプリケーションにpingを送信
  scheduler.every '14m' do
    begin
      uri = URI(app_url)
      response = Net::HTTP.get_response(uri)
      Rails.logger.info "Ping to #{app_url} completed with status: #{response.code}"
    rescue => e
      Rails.logger.error "Ping to #{app_url} failed: #{e.message}"
    end
  end
end 