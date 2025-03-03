class Job < ApplicationRecord
  belongs_to :company_profile
  belongs_to :location
  belongs_to :employment_type
  belongs_to :work_style
  
  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills
  has_many :likes, dependent: :destroy
  
  validates :title, presence: true
  validates :description, presence: true
  validates :salary, presence: true, numericality: { greater_than: 0 }
  
  # アクティブな（有効な）求人のみを取得するスコープ
  # デフォルトではすべての求人をアクティブとみなす
  scope :active, -> { all }
end
