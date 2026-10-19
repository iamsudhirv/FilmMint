class Connection < ApplicationRecord
  belongs_to :person
  belongs_to :other_person, class_name: "Person"

  validates :strength, inclusion: { in: 1..5 }
  validate :not_self_link
  validate :not_duplicate

  private

  def not_duplicate
    return unless Connection.where(person_id: [ person_id, other_person_id ], other_person_id: [ person_id, other_person_id ]).where.not(id: id).exists?
    errors.add(:base, "You are already connected")
  end

  def not_self_link
    errors.add(:other_person_id, "can't be the same person") if person_id == other_person_id
  end
end
