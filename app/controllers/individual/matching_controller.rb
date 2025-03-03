class Individual::MatchingController < ApplicationController
  before_action :require_login
  layout 'individual/application'
  
  def index
    @user = current_user
    Rails.logger.debug "マッチング画面を表示します: ユーザーID=#{@user.user_id}" if Rails.env.development?
  end
end
