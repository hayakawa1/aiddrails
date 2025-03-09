class Company::MessagesController < ApplicationController
  before_action :ensure_company_user
  before_action :set_conversation, only: [:show, :create]
  layout 'company/application'
  
  def index
    @user = current_user
    @conversations = @user.conversations
                          .includes(:target_user, :job, :messages)
                          .order('messages.created_at DESC')
                          .distinct
  end

  def show
    @messages = @conversation.messages.includes(:sender).order(created_at: :asc)
    
    # 相手が送信した未読メッセージを既読にする
    @messages.where.not(sender_id: current_user.id).where(read: false).update_all(read: true)
    
    # 新規メッセージのためのインスタンス
    @message = Message.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.sender_id = current_user.id
    
    if @message.save
      redirect_to company_message_path(@conversation), notice: 'メッセージを送信しました'
    else
      @messages = @conversation.messages.includes(:sender).order(created_at: :asc)
      render :show
    end
  end
  
  def unread_count
    count = current_user.conversations
                       .joins(:messages)
                       .where.not('messages.sender_id': current_user.id)
                       .where('messages.read': false)
                       .count
    
    render json: { count: count }
  end

  private

  def set_conversation
    # 指定されたIDでまず探す（createアクションの場合はconversation_idを使用）
    conversation_id = params[:id] || params[:conversation_id]
    conversation = Conversation.find_by(id: conversation_id)
    
    # もしなければ、target_user_idとjob_idから探す
    if conversation.nil? && params[:target_user_id].present? && params[:job_id].present?
      conversation = Conversation.find_or_create_by(
        user_id: current_user.id,
        target_user_id: params[:target_user_id],
        job_id: params[:job_id]
      )
    end
    
    # 会話が見つからない、または現在のユーザーに関連していない場合はリダイレクト
    if conversation.nil? || conversation.user_id != current_user.id
      redirect_to company_messages_path, alert: '指定された会話が見つかりません'
      return
    end
    
    # マッチングしていない場合はアクセス不可
    unless conversation.matched?
      redirect_to company_messages_path, alert: 'マッチングしていないユーザーとはメッセージを交換できません'
      return
    end
    
    @conversation = conversation
  end

  def message_params
    params.require(:message).permit(:content)
  end
  
  def ensure_company_user
    unless current_user.user_type == "法人"
      redirect_to root_path, alert: '権限がありません'
    end
  end
end
