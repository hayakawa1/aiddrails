class EmploymentType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }
  
  has_many :user_employment_types, dependent: :destroy
  has_many :users, through: :user_employment_types
end
