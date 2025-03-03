class UsersController < ApplicationController
  def new
    @user = User.new
    # デバッグ用のログ出力
    puts "新規ユーザー登録フォームを表示します"
    Rails.logger.debug "新規ユーザー登録フォームを表示します" if Rails.env.development?
  end

  def create
    # デバッグ用のログ出力
    puts "ユーザー登録処理を開始します"
    puts "送信されたパラメータ: #{params.inspect}"
    Rails.logger.debug "ユーザー登録処理を開始します" if Rails.env.development?
    Rails.logger.debug "送信されたパラメータ: #{params.inspect}" if Rails.env.development?
    
    @user = User.new(user_params)
    
    if @user.save
      # 登録成功時
      puts "ユーザー登録が成功しました: #{@user.user_id}"
      Rails.logger.debug "ユーザー登録が成功しました: #{@user.user_id}" if Rails.env.development?
      
      flash[:success] = "会員登録が完了しました"
      redirect_to root_path
    else
      # 登録失敗時
      puts "ユーザー登録が失敗しました: #{@user.errors.full_messages.join(', ')}"
      Rails.logger.debug "ユーザー登録が失敗しました: #{@user.errors.full_messages.join(', ')}" if Rails.env.development?
      
      flash.now[:error] = "登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:user_id, :password, :user_type)
  end
end
