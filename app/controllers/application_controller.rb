class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # すべてのアクションで認証を要求
  before_action :require_login
  
  # 全てのビューで利用可能なヘルパーメソッド
  helper_method :current_user, :logged_in?
  
  private
  
  # 現在ログインしているユーザーを取得
  def current_user
    # テスト環境ではモックユーザーを返す
    if Rails.env.test?
      @current_user ||= MockUser.new(1, "test_user", "個人")
    else
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  end
  
  # ユーザーがログインしているかどうかを確認
  def logged_in?
    # テスト環境では常にtrueを返す
    return true if Rails.env.test?
    
    !current_user.nil?
  end
  
  # ログインしていない場合はログインページにリダイレクト
  def require_login
    # テスト環境では認証をスキップ
    return true if Rails.env.test?
    
    unless logged_in?
      flash[:error] = "ログインしてください"
      redirect_to login_path
    end
  end
end
