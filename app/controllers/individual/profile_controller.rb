class Individual::ProfileController < ApplicationController
  before_action :require_login
  layout 'individual/application'
  
  def show
    @user = current_user
    Rails.logger.debug "プロフィール画面を表示します: ユーザーID=#{@user.user_id}" if Rails.env.development?
  end

  def edit
    @user = current_user
    @profile = @user.individual_profile || @user.build_individual_profile
    
    # マスターデータの取得
    @locations = Location.all
    @employment_types = EmploymentType.all
    @work_styles = WorkStyle.all
    @skills = Skill.all
    
    # ユーザーが選択しているスキルのIDとレベルのハッシュを作成
    @user_skills_hash = {}
    @user.user_skills.each do |user_skill|
      @user_skills_hash[user_skill.skill_id] = user_skill.level
    end
    
    Rails.logger.debug "プロフィール編集画面を表示します: ユーザーID=#{@user.user_id}" if Rails.env.development?
  end
  
  def update
    @user = current_user
    @profile = @user.individual_profile || @user.build_individual_profile
    
    # トランザクション開始
    ActiveRecord::Base.transaction do
      # プロフィール情報の更新
      profile_params = params.require(:profile).permit(:display_name, :birth_year, :bio, :desired_salary)
      @profile.update!(profile_params)
      
      # 勤務地の更新
      @user.location_ids = params[:location_ids] || []
      
      # 雇用形態の更新
      @user.employment_type_ids = params[:employment_type_ids] || []
      
      # 勤務形態の更新
      @user.work_style_ids = params[:work_style_ids] || []
      
      # スキルの更新
      @user.user_skills.destroy_all # 既存のスキルを削除
      
      if params[:skill_ids].present?
        params[:skill_ids].each do |skill_id|
          level = params[:skill_levels][skill_id].to_i if params[:skill_levels] && params[:skill_levels][skill_id].present?
          @user.user_skills.create!(skill_id: skill_id, level: level || 1)
        end
      end
    end
    
    flash[:success] = "プロフィールを更新しました"
    redirect_to individual_profile_show_path
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = "プロフィールの更新に失敗しました: #{e.message}"
    
    # マスターデータを再取得
    @locations = Location.all
    @employment_types = EmploymentType.all
    @work_styles = WorkStyle.all
    @skills = Skill.all
    
    # ユーザースキルハッシュを再構築
    @user_skills_hash = {}
    @user.user_skills.each do |user_skill|
      @user_skills_hash[user_skill.skill_id] = user_skill.level
    end
    
    render :edit
  end
end
