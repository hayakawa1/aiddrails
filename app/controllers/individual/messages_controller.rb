class Individual::MessagesController < ApplicationController
  before_action :ensure_individual_user
  before_action :set_conversation, only: [:show, :create]
  layout 'individual/application'
  
  def index
    @user = current_user
    @conversations = @user.target_conversations
                          .includes(:user, :job, :messages)
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
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.new(message_params)
    @message.sender_id = current_user.id
    
    if @message.save
      redirect_to individual_message_path(@conversation), notice: 'メッセージを送信しました'
    else
      @messages = @conversation.messages.includes(:sender).order(created_at: :asc)
      render :show
    end
  end
  
  def unread_count
    count = current_user.target_conversations
                       .joins(:messages)
                       .where.not('messages.sender_id': current_user.id)
                       .where('messages.read': false)
                       .count
    
    render json: { count: count }
  end

  private

  def set_conversation
    # 指定されたIDでまず探す（idまたはconversation_idパラメータを使用）
    conversation_id = params[:id] || params[:conversation_id]
    conversation = Conversation.find_by(id: conversation_id)
    
    # 会話が見つからない、または現在のユーザーに関連していない場合はリダイレクト
    if conversation.nil? || conversation.target_user_id != current_user.id
      redirect_to individual_messages_path, alert: '指定された会話が見つかりません'
      return
    end
    
    # マッチングしていない場合はアクセス不可
    unless conversation.matched?
      redirect_to individual_messages_path, alert: 'マッチングしていない企業とはメッセージを交換できません'
      return
    end
    
    @conversation = conversation
  end

  def message_params
    params.require(:message).permit(:content)
  end
  
  def ensure_individual_user
    unless current_user.user_type == "個人"
      redirect_to root_path, alert: '権限がありません'
    end
  end
end
