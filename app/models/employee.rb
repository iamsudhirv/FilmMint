class Employee < ApplicationRecord
  belongs_to :department
  has_one :salary_structure, dependent: :destroy
  has_many :payslips, dependent: :destroy

  accepts_nested_attributes_for :salary_structure, update_only: true

  validates :first_name, :last_name, :email, :employee_code, :designation, :date_of_joining, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employee_code, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: %w[active on_leave terminated] }

  scope :active, -> { where(status: 'active') }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def current_gross_salary
    salary_structure&.gross_monthly || 0.0
  end

  def active?
    status == 'active'
  end
end
