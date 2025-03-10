class HomeController < ApplicationController
  # ホーム画面へのアクセスは認証不要
  skip_before_action :require_login, only: [:index, :engineer_info, :company_info, :about_aidd]

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

  # エンジニア向け情報ページ
  def engineer_info
  end

  # 企業向け情報ページ
  def company_info
  end

  # AI駆動開発とはページ
  def about_aidd
  end
end
