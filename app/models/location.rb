class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }
  
  has_many :user_locations, dependent: :destroy
  has_many :users, through: :user_locations
end
