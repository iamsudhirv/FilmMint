class Project < ApplicationRecord
  LEANINGS = %w[none left center right].freeze
  STATUSES = %w[development financing pre_production production post].freeze

  has_many :package_members, dependent: :destroy
  has_many :people, through: :package_members

  validates :title, presence: true
  validates :political_leaning, inclusion: { in: LEANINGS }
  validates :status, inclusion: { in: STATUSES }
  validates :budget_usd, numericality: { greater_than: 0 }, allow_nil: true
end
