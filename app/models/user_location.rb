class UserLocation < ApplicationRecord
  belongs_to :user
  belongs_to :location
  
  validates :user_id, uniqueness: { scope: :location_id, message: "は既にこの勤務地を選択しています" }
end
