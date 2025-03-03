class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill
  
  validates :user_id, uniqueness: { scope: :skill_id, message: "は既にこのスキルを選択しています" }
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
end
