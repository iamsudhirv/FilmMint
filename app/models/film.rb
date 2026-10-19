class Film < ApplicationRecord
  has_many :credits, dependent: :destroy
  has_many :people, through: :credits
  has_many :territory_performances, dependent: :destroy

  validates :title, presence: true
  validates :industry, inclusion: { in: Industry::KEYS }

  # Real films store a worldwide total; demo films have a territory split we can add up.
  def worldwide_gross_usd
    self[:worldwide_gross_usd] || territory_performances.sum(:gross_usd).then { |total| total.positive? ? total : nil }
  end
end
