class Invoice < ApplicationRecord
  belongs_to :individual_user, class_name: 'User'
  belongs_to :company_user, class_name: 'User'
  belongs_to :job

  validates :occurred_at, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid, inclusion: { in: [true, false] }
  
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }
  
  def mark_as_paid!
    update!(paid: true)
  end
  
  def mark_as_unpaid!
    update!(paid: false)
  end
end
