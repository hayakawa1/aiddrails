class TestController < ApplicationController
  # テスト環境でのみ使用するコントローラー
  skip_before_action :require_login
  
  def index
    render plain: "Test controller"
  end
end 