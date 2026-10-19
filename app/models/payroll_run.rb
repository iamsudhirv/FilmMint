class PayrollRun < ApplicationRecord
  has_many :payslips, dependent: :destroy
  has_many :employees, through: :payslips

  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true, numericality: { greater_than_or_equal_to: 2000, less_than_or_equal_to: 2100 }
  validates :month, uniqueness: { scope: :year, message: "payroll run already exists for this month and year" }
  validates :status, inclusion: { in: %w[draft reviewed approved paid] }

  def period_name
    Date.new(year, month, 1).strftime("%B %Y")
  end

  def recalculate_totals!
    reload
    self.total_gross = payslips.sum(:gross_earnings)
    self.total_deductions = payslips.sum(:total_deductions)
    self.total_net_pay = payslips.sum(:net_pay)
    self.employees_count = payslips.count
    save!
  end
end
