class User < ApplicationRecord
  validates :user_id, presence: true, uniqueness: true
  validates :password, presence: true
  validates :user_type, presence: true

  # 関連付け
  has_one :individual_profile, dependent: :destroy
  has_one :company_profile, dependent: :destroy
  
  has_many :user_locations, dependent: :destroy
  has_many :locations, through: :user_locations
  
  has_many :user_employment_types, dependent: :destroy
  has_many :employment_types, through: :user_employment_types
  
  has_many :user_work_styles, dependent: :destroy
  has_many :work_styles, through: :user_work_styles
  
  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills

  # パスワードをハッシュ化して保存するためのメソッド
  def password=(raw_password)
    if raw_password.present?
      self[:password] = BCrypt::Password.create(raw_password)
    end
  end

  # 認証用メソッド
  def authenticate(raw_password)
    return false unless password.present?
    BCrypt::Password.new(password) == raw_password
  end
end
