class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }

  def total_employees
    employees.count
  end

  def active_employees_count
    employees.where(status: 'active').count
  end
end
