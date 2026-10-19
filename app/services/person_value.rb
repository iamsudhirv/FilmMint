# How much worldwide box office each territory has historically attributed to a person,
# based on the films they were credited on. Lead billing counts for more.
class PersonValue
  BILLING_WEIGHTS = { 1 => 1.0, 2 => 0.7, 3 => 0.5 }.freeze
  DEFAULT_BILLING_WEIGHT = 0.3
  ROLE_WEIGHTS = { "actor" => 1.0, "director" => 0.6 }.freeze
  DEFAULT_ROLE_WEIGHT = 0.2

  def initialize(person)
    @person = person
  end

  def film_count
    credits.size
  end

  # { territory_id => average weighted gross (USD) per film }
  def by_territory
    @by_territory ||= begin
      totals = Hash.new(0.0)
      credits.each do |credit|
        weight = credit_weight(credit)
        credit.film.territory_performances.each { |tp| totals[tp.territory_id] += tp.gross_usd * weight }
      end
      totals.transform_values { |v| (v / credits.size).round }
    end
  end

  private

  def credits
    @credits ||= @person.credits.includes(film: :territory_performances).to_a
  end

  def credit_weight(credit)
    billing = BILLING_WEIGHTS.fetch(credit.billing_order, DEFAULT_BILLING_WEIGHT)
    role = ROLE_WEIGHTS.fetch(credit.role, DEFAULT_ROLE_WEIGHT)
    billing * role
  end
end
