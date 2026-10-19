class PackageMember < ApplicationRecord
  belongs_to :project
  belongs_to :person

  validates :role, presence: true
  validates :person_id, uniqueness: { scope: :project_id }

  def effective_fee_usd
    fee_usd || person.fee_usd || 0
  end
end
