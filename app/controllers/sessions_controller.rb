class SessionsController < ApplicationController
  # ログイン関連のアクセスは認証不要
  skip_before_action :require_login, except: [:destroy]

  def new
    # ログインフォームを表示するだけ
    Rails.logger.debug "ログインフォームを表示します" if Rails.env.development?
  end

  def create
    # パラメータからユーザーIDを取得
    user_id = params[:session][:user_id]
    password = params[:session][:password]
    
    Rails.logger.debug "ログイン処理を開始します: ユーザーID=#{user_id}" if Rails.env.development?
    
    # ユーザーを検索
    @user = User.find_by(user_id: user_id)
    
    # ユーザーが存在し、パスワードが一致するか確認
    if @user && @user.authenticate(password)
      # ログイン成功：セッションにユーザーIDを保存
      session[:user_id] = @user.id
      Rails.logger.debug "ログイン成功: ユーザーID=#{user_id}, タイプ=#{@user.user_type}" if Rails.env.development?
      
      flash[:success] = "ログインしました"
      
      # ユーザー種別に応じてリダイレクト先を変更
      if @user.user_type == "個人"
        redirect_to individual_root_path
      elsif @user.user_type == "法人"
        redirect_to company_root_path
      else
        redirect_to root_path
      end
    else
      # ログイン失敗
      Rails.logger.debug "ログイン失敗: ユーザーIDまたはパスワードが正しくありません" if Rails.env.development?
      
      flash.now[:error] = "ユーザーIDまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # セッションからユーザーIDを削除してログアウト
    session.delete(:user_id)
    Rails.logger.debug "ログアウトしました" if Rails.env.development?
    
    flash[:success] = "ログアウトしました"
    redirect_to login_path
  end
end
