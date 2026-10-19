class TerritoryPerformance < ApplicationRecord
  belongs_to :film
  belongs_to :territory

  validates :gross_usd, numericality: { greater_than_or_equal_to: 0 }
end
