class Individual::MatchingController < ApplicationController
  before_action :require_login
  layout 'individual/application'
  
  def index
    @user = current_user
    Rails.logger.debug "マッチング画面を表示します: ユーザーID=#{@user.id}" if Rails.env.development?
    
    # ユーザーにマッチする求人を取得
    @matching_jobs = MatchingService.find_matching_jobs_for_user(@user.id)
    
    # ユーザーがいいねした求人のIDリストを取得
    @liked_job_ids = @user.likes.pluck(:job_id)
  end
  
  def show
    @job = Job.find(params[:id])
    @company = @job.company_profile
    @user = current_user
    @liked = @user.likes.exists?(job_id: @job.id)
  end
  
  def like
    @job = Job.find(params[:id])
    @user = current_user
    
    # すでにいいねしているか確認
    if @user.likes.exists?(job_id: @job.id)
      # すでにいいねしている場合は何もしない
      render json: { status: 'already_liked' }
      return
    end
    
    # いいねを作成
    like = Like.new(user: @user, job: @job)
    
    if like.save
      # マッチしたかどうかを確認（企業側もいいねしているか）
      company_user = @job.company_profile.user
      matched = company_user.likes.exists?(target_user_id: @user.id, job_id: @job.id)
      
      # マッチングした場合は会話を作成
      if matched
        # すでに会話が存在するか確認
        conversation = Conversation.find_or_create_by(
          user_id: company_user.id,
          target_user_id: @user.id,
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
    @job = Job.find(params[:id])
    @user = current_user
    like = @user.likes.find_by(job_id: @job.id)
    
    if like&.destroy
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: 'いいねの取り消しに失敗しました' }, status: :unprocessable_entity
    end
  end
end
