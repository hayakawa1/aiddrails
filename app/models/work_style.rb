class WorkStyle < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }
  
  has_many :user_work_styles, dependent: :destroy
  has_many :users, through: :user_work_styles
end
