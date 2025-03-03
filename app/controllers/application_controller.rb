class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # 全てのビューで利用可能なヘルパーメソッド
  helper_method :current_user, :logged_in?
  
  private
  
  # 現在ログインしているユーザーを取得
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  # ユーザーがログインしているかどうかを確認
  def logged_in?
    !current_user.nil?
  end
  
  # ログインしていない場合はログインページにリダイレクト
  def require_login
    unless logged_in?
      flash[:error] = "ログインしてください"
      redirect_to login_path
    end
  end
end
