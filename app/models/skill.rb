class Skill < ApplicationRecord
  validates :category, presence: true
  validates :description, length: { maximum: 1000 }
  
  has_many :user_skills, dependent: :destroy
  has_many :users, through: :user_skills
end
