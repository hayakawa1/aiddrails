class Like < ApplicationRecord
  belongs_to :user
  belongs_to :job
  belongs_to :target_user, class_name: 'User', optional: true
  
  # 個人ユーザーの場合のバリデーション（target_user_idがない場合）
  validates :user_id, uniqueness: { 
    scope: :job_id,
    message: "既にこの求人にいいねしています"
  }, unless: -> { target_user_id.present? }
  
  # 企業ユーザーの場合のバリデーション（target_user_idがある場合）
  validates :target_user_id, uniqueness: { 
    scope: [:user_id, :job_id],
    message: "既にこの求職者にいいねしています"
  }, if: -> { target_user_id.present? }
  
  # カスタムバリデーション
  validate :validate_user_type
  
  private
  
  def validate_user_type
    if target_user_id.present? && user.user_type != "法人"
      errors.add(:base, "法人ユーザーのみが求職者にいいねできます")
    elsif target_user_id.nil? && user.user_type != "個人"
      errors.add(:base, "個人ユーザーのみが求人にいいねできます")
    end
  end
end
