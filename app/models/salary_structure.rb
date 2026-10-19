class SalaryStructure < ApplicationRecord
  belongs_to :employee

  validates :base_salary, numericality: { greater_than_or_equal_to: 0 }
  validates :hra, :special_allowance, :conveyance_allowance, :medical_allowance,
            numericality: { greater_than_or_equal_to: 0 }
  validates :pf_deduction_rate, :esi_deduction_rate, :tds_tax_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :professional_tax, numericality: { greater_than_or_equal_to: 0 }

  def total_allowances
    (hra || 0) + (special_allowance || 0) + (conveyance_allowance || 0) + (medical_allowance || 0)
  end

  def gross_monthly
    (base_salary || 0) + total_allowances
  end

  def annual_ctc
    gross_monthly * 12
  end
end
