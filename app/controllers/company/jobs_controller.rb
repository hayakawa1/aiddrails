class Company::JobsController < ApplicationController
  before_action :require_login
  before_action :require_company_user
  before_action :set_company_profile
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  layout 'company/application'
  
  def index
    @jobs = @company_profile.jobs.order(created_at: :desc)
  end

  def show
  end

  def new
    @job = @company_profile.jobs.build
    # マスターデータの取得
    load_master_data
  end

  def create
    @job = @company_profile.jobs.build(job_params)
    
    # トランザクション開始
    ActiveRecord::Base.transaction do
      @job.save!
      
      # スキルの登録
      if params[:skill_ids].present?
        params[:skill_ids].each do |skill_id|
          level = params[:skill_levels][skill_id].to_i if params[:skill_levels] && params[:skill_levels][skill_id].present?
          @job.job_skills.create!(skill_id: skill_id, level: level || 1)
        end
      end
      
      flash[:success] = "求人を作成しました"
      redirect_to company_job_path(@job)
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = "求人の作成に失敗しました: #{e.message}"
    load_master_data
    render :new
  end

  def edit
    # マスターデータの取得
    load_master_data
    
    # 求人に登録されているスキルとレベルのハッシュを作成
    @job_skills_hash = {}
    @job.job_skills.each do |job_skill|
      @job_skills_hash[job_skill.skill_id] = job_skill.level
    end
  end

  def update
    # トランザクション開始
    ActiveRecord::Base.transaction do
      @job.update!(job_params)
      
      # スキルの更新
      @job.job_skills.destroy_all # 既存のスキルを削除
      
      if params[:skill_ids].present?
        params[:skill_ids].each do |skill_id|
          level = params[:skill_levels][skill_id].to_i if params[:skill_levels] && params[:skill_levels][skill_id].present?
          @job.job_skills.create!(skill_id: skill_id, level: level || 1)
        end
      end
      
      flash[:success] = "求人を更新しました"
      redirect_to company_job_path(@job)
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = "求人の更新に失敗しました: #{e.message}"
    load_master_data
    
    # 求人スキルハッシュを再構築
    @job_skills_hash = {}
    @job.job_skills.each do |job_skill|
      @job_skills_hash[job_skill.skill_id] = job_skill.level
    end
    
    render :edit
  end

  def destroy
    @job.destroy
    flash[:success] = "求人を削除しました"
    redirect_to company_jobs_path
  end
  
  private
  
  def set_company_profile
    @company_profile = current_user.company_profile
    unless @company_profile
      flash[:error] = "会社プロフィールを先に設定してください"
      redirect_to company_profile_edit_path
    end
  end
  
  def set_job
    @job = @company_profile.jobs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "求人が見つかりませんでした"
    redirect_to company_jobs_path
  end
  
  def job_params
    params.require(:job).permit(
      :title, :description, :employment_type_id, :work_style_id, :location_id, :salary_min, :legal_info
    )
  end
  
  def load_master_data
    @employment_types = EmploymentType.all
    @work_styles = WorkStyle.all
    @locations = Location.all
    @skills = Skill.all
  end
  
  def require_company_user
    unless current_user.user_type == "法人"
      flash[:error] = "この機能は法人ユーザーのみ利用できます"
      redirect_to root_path
    end
  end
end
