class Like < ApplicationRecord
  belongs_to :user
  belongs_to :job
  belongs_to :target_user, class_name: 'User', optional: true
  
  # 同じユーザーが同じ求人に対して複数回「いいね」できないようにする
  validates :user_id, uniqueness: { scope: :job_id }
  
  # 企業ユーザーが同じ個人と求人の組み合わせに対して複数回「いいね」できないようにする
  validates :target_user_id, uniqueness: { scope: [:user_id, :job_id] }, if: -> { target_user_id.present? }
end
