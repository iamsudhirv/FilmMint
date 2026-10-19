class PayslipItem < ApplicationRecord
  belongs_to :payslip

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: %w[earning deduction] }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
