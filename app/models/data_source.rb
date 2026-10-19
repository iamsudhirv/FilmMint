class DataSource < ApplicationRecord
  CATEGORIES = %w[box_office_revenue metadata ratings awards streaming news datasets].freeze
  ACCESS_METHODS = %w[api dataset scrape].freeze
  TOS_STATUSES = %w[allowed prohibited unknown].freeze

  validates :name, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :access_method, inclusion: { in: ACCESS_METHODS }
  validates :tos_status, inclusion: { in: TOS_STATUSES }
end
