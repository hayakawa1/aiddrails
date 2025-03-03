class Company::MatchingController < ApplicationController
  before_action :require_login
  before_action :ensure_company_user
  layout 'company/application'

  def index
    @user = current_user
    @company_profile = @user.company_profile
    @jobs = @company_profile.jobs
  end
  
  def search
    @user = current_user
    @company_profile = @user.company_profile
    @jobs = @company_profile.jobs
    
    @selected_job_id = params[:job_id]
    
    if @selected_job_id.present?
      @selected_job = Job.find(@selected_job_id)
      @matching_users = MatchingService.find_matching_users_for_job(@selected_job_id)
      
      # いいね済みユーザーのIDリストを取得
      @liked_user_ids = @user.likes.where(job_id: @selected_job_id).pluck(:user_id)
    else
      @matching_users = []
      @liked_user_ids = []
    end
    
    render :index
  end

  def show
    @user = User.find(params[:id])
    @individual_profile = @user.individual_profile
    @job_id = params[:job_id]
    @job = Job.find(@job_id) if @job_id.present?
    @liked = current_user.likes.exists?(user_id: @user.id, job_id: @job_id)
    
    # ユーザーのスキル情報を取得
    @user_skills = @user.user_skills.includes(:skill)
    
    # マッチングスコアを計算
    matching_data = MatchingService.calculate_matching_score(@user.id, @job_id)
    @matching_score = matching_data[:total_score]
    @condition_match_score = matching_data[:condition_match_score]
    @skill_match_score = matching_data[:skill_match_score]
  end

  def like
    @target_user = User.find(params[:id])
    @job = Job.find(params[:job_id])
    @current_user = current_user
    
    # すでにいいねしているか確認
    if @current_user.likes.exists?(target_user_id: @target_user.id, job_id: @job.id)
      # すでにいいねしている場合は何もしない
      render json: { status: 'already_liked' }
      return
    end
    
    # いいねを作成
    like = Like.new(user: @current_user, target_user: @target_user, job: @job)
    
    if like.save
      # マッチしたかどうかを確認（個人側もいいねしているか）
      matched = @target_user.likes.exists?(job_id: @job.id)
      
      # マッチングした場合は会話を作成
      if matched
        # すでに会話が存在するか確認
        conversation = Conversation.find_or_create_by(
          user_id: @current_user.id,
          target_user_id: @target_user.id,
          job_id: @job.id
        )
      end
      
      render json: { 
        status: 'success', 
        matched: matched,
        conversation_id: (matched ? conversation.id : nil)
      }
    else
      render json: { status: 'error', message: like.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end
  
  def unlike
    @target_user = User.find(params[:id])
    @job = Job.find(params[:job_id])
    @current_user = current_user
    
    like = @current_user.likes.find_by(target_user_id: @target_user.id, job_id: @job.id)
    
    if like&.destroy
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: 'いいねの取り消しに失敗しました' }, status: :unprocessable_entity
    end
  end
  
  private
  
  def ensure_company_user
    unless current_user.user_type == "法人"
      flash[:alert] = "法人ユーザーのみアクセス可能です"
      redirect_to root_path
    end
  end
end
