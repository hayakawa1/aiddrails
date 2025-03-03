class IndividualProfile < ApplicationRecord
  belongs_to :user
  
  validates :display_name, presence: true, length: { maximum: 50 }
  validates :birth_year, numericality: { 
    only_integer: true, 
    greater_than: 1900, 
    less_than_or_equal_to: -> { Date.current.year } 
  }, allow_nil: true
  validates :bio, length: { maximum: 1000 }
end
