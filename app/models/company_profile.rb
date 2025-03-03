class CompanyProfile < ApplicationRecord
  belongs_to :user
  has_many :jobs, dependent: :destroy
  
  validates :company_name, presence: true
  validates :website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
end
