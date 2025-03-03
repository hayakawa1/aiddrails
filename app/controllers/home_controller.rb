class HomeController < ApplicationController
  def index
    # ログイン済みの場合はユーザー種別に応じたダッシュボードにリダイレクト
    if logged_in?
      if current_user.user_type == "個人"
        redirect_to individual_profile_show_path
      elsif current_user.user_type == "法人"
        redirect_to company_profile_show_path
      end
    end
    # ログインしていない場合はトップページを表示（デフォルト動作）
  end
end
