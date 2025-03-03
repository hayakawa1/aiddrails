class Conversation < ApplicationRecord
  belongs_to :user     # 会社側
  belongs_to :target_user, class_name: 'User'  # 個人側
  belongs_to :job
  
  has_many :messages, dependent: :destroy
  
  # マッチングをチェックするためのメソッド
  def matched?
    # 会社側と個人側の両方がいいねしているかをチェック
    company_like = Like.exists?(user_id: user_id, target_user_id: target_user_id, job_id: job_id)
    individual_like = Like.exists?(user_id: target_user_id, job_id: job_id)
    
    company_like && individual_like
  end
  
  # 最新メッセージを取得
  def latest_message
    messages.order(created_at: :desc).first
  end
  
  # 未読メッセージ数を取得
  def unread_count(user_id)
    messages.where.not(sender_id: user_id).where(read: false).count
  end
end
