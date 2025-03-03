class JobSkill < ApplicationRecord
  belongs_to :job
  belongs_to :skill
  
  validates :job_id, uniqueness: { scope: :skill_id, message: "はすでにこのスキルを追加しています" }
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
end
