class UserEmploymentType < ApplicationRecord
  belongs_to :user
  belongs_to :employment_type
  
  validates :user_id, uniqueness: { scope: :employment_type_id, message: "は既にこの雇用形態を選択しています" }
end
