class Territory < ApplicationRecord
  has_many :territory_performances, dependent: :destroy

  validates :name, :code, presence: true
  validates :code, uniqueness: true
  validates :kind, inclusion: { in: %w[country group] }

  default_scope { order(:position) }
end
