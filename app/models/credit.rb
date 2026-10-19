class Credit < ApplicationRecord
  belongs_to :person
  belongs_to :film

  validates :role, presence: true
  validates :billing_order, numericality: { greater_than: 0 }
end
