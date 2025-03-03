class Job < ApplicationRecord
  belongs_to :company_profile
  belongs_to :employment_type
  belongs_to :work_style
  belongs_to :location
  
  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills
  
  validates :title, presence: true
  validates :description, presence: true
  validates :salary_min, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :salary_max, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :salary_max_greater_than_min
  
  private
  
  def salary_max_greater_than_min
    return if salary_min.blank? || salary_max.blank?
    
    if salary_max <= salary_min
      errors.add(:salary_max, "は最低額より大きい金額を設定してください")
    end
  end
end
