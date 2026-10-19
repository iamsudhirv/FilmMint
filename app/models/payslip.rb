class Payslip < ApplicationRecord
  belongs_to :payroll_run
  belongs_to :employee
  has_many :payslip_items, dependent: :destroy

  validates :payslip_number, presence: true, uniqueness: true
  validates :employee_id, uniqueness: { scope: :payroll_run_id, message: "already has a payslip in this payroll run" }
  validates :payment_status, inclusion: { in: %w[pending paid] }
  validates :status, inclusion: { in: %w[draft confirmed] }

  def earnings
    payslip_items.where(category: 'earning')
  end

  def deductions
    payslip_items.where(category: 'deduction')
  end
end
