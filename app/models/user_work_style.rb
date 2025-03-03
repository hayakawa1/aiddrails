class UserWorkStyle < ApplicationRecord
  belongs_to :user
  belongs_to :work_style
  
  validates :user_id, uniqueness: { scope: :work_style_id, message: "は既にこの勤務形態を選択しています" }
end
