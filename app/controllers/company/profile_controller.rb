class Company::ProfileController < ApplicationController
  layout 'company/application'
  before_action :require_login
  before_action :require_company_user
  
  def show
    @user = current_user
    Rails.logger.debug "プロフィール画面を表示します: ユーザーID=#{@user.user_id}"
  end

  def edit
    @user = current_user
    @company_profile = @user.company_profile || @user.build_company_profile
    Rails.logger.debug "プロフィール編集画面を表示します: ユーザーID=#{@user.user_id}"
  end

  def update
    @user = current_user
    @company_profile = @user.company_profile || @user.build_company_profile
    
    ActiveRecord::Base.transaction do
      if @company_profile.update(profile_params)
        flash[:success] = "プロフィールが更新されました"
        redirect_to company_profile_show_path
      else
        flash.now[:error] = "更新できませんでした"
        render :edit, status: :unprocessable_entity
      end
    end
  end
  
  private
  
  def profile_params
    params.require(:profile).permit(:company_name, :description, :website_url)
  end
  
  def require_company_user
    unless current_user.user_type == "法人"
      flash[:error] = "法人ユーザーのみアクセスできます"
      redirect_to root_path
    end
  end
end
