class Person < ApplicationRecord
  KINDS = %w[actor director producer cinematographer writer agent sales_agent].freeze
  POLITICS = %w[left center right].freeze

  has_many :credits, dependent: :destroy
  has_many :films, through: :credits
  has_many :package_members, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :inverse_connections, class_name: "Connection", foreign_key: :other_person_id, dependent: :destroy

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :industry, inclusion: { in: Industry::KEYS }
  validates :politics_lean, inclusion: { in: POLITICS }, allow_nil: true
  validates :controversy_level, inclusion: { in: 0..3 }

  scope :search, ->(q) { where("people.name ILIKE ?", "%#{sanitize_sql_like(q)}%") }
  scope :bookable, -> { where(is_self: false) }
end
