class Company::MatchingController < ApplicationController
  before_action :require_login
  before_action :ensure_company_user
  layout 'company/application'

  def index
    @user = current_user
    @company_profile = @user.company_profile
    
    if @company_profile.nil?
      # 企業プロファイルが存在しない場合はプロファイル編集ページへリダイレクト
      flash[:alert] = "企業プロファイルを作成してください"
      redirect_to company_profile_edit_path and return
    end
    
    @jobs = @company_profile.jobs
  end
  
  def search
    @user = current_user
    @company_profile = @user.company_profile
    
    if @company_profile.nil?
      # 企業プロファイルが存在しない場合はプロファイル編集ページへリダイレクト
      flash[:alert] = "企業プロファイルを作成してください"
      redirect_to company_profile_edit_path and return
    end
    
    @jobs = @company_profile.jobs
    
    @selected_job_id = params[:job_id]
    
    if @selected_job_id.present?
      @selected_job = Job.find(@selected_job_id)
      @matching_users = MatchingService.find_matching_users_for_job(@selected_job_id)
      
      # いいね済みユーザーのIDリストを取得（修正）
      @liked_user_ids = @user.likes.where(job_id: @selected_job_id, target_user_id: @matching_users.pluck(:id)).pluck(:target_user_id)
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
    @liked = current_user.likes.exists?(target_user_id: @user.id, job_id: @job_id)
    
    # ユーザーのスキル情報を取得
    @user_skills = @user.user_skills.includes(:skill)
    
    # マッチングの一致を確認（スコア計算は行わない）
    @is_match = MatchingService.is_mutual_match(@user.id, @job_id) if @user && @job_id.present?
  end

  def like
    @target_user = User.find(params[:id])
    @job = Job.find(params[:job_id])
    @current_user = current_user
    
    # すでにいいねしているか確認
    if @current_user.likes.exists?(target_user_id: @target_user.id, job_id: @job.id)
      # すでにいいねしている場合は何もしない
      Rails.logger.info "Already liked: user_id=#{@current_user.id}, target_user_id=#{@target_user.id}, job_id=#{@job.id}"
      render json: { status: 'already_liked' }
      return
    end
    
    # いいねを作成
    like = Like.new(
      user: @current_user,
      target_user: @target_user,
      job: @job
    )
    
    if like.save
      Rails.logger.info "Like created: user_id=#{@current_user.id}, target_user_id=#{@target_user.id}, job_id=#{@job.id}"
      
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
        Rails.logger.info "Match found and conversation created: conversation_id=#{conversation.id}"
        
        # マッチング成立時に請求レコードを作成
        MatchingService.create_invoice_for_match(@target_user.id, @current_user.id, @job.id)
      end
      
      render json: { 
        status: 'success', 
        matched: matched,
        conversation_id: (matched ? conversation.id : nil)
      }
    else
      Rails.logger.error "Failed to create like: #{like.errors.full_messages.join(', ')}"
      render json: { 
        status: 'error', 
        message: like.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
  end
  
  def unlike
    @target_user = User.find(params[:id])
    @job = Job.find(params[:job_id])
    
    # いいねの削除は行わず、成功レスポンスを返す
    render json: { status: 'success', message: 'いいねは取り消せません' }
  end
  
  private
  
  def ensure_company_user
    unless current_user.user_type == "法人"
      flash[:alert] = "法人ユーザーのみアクセス可能です"
      redirect_to root_path
    end
  end
end
