# Heuristic valuation of a project's package (cast + key crew).
#
# Estimates foreign/domestic presale potential per territory from each person's
# historical territory performance, compares expected sales to their fee, and
# produces a simple, explainable risk score. All constants are tunable assumptions,
# not industry truth - the output is decision support, not a decision.
class PackageValuation
  PRESALE_RATIO = 0.05      # share of attributed historical gross a buyer might pay up-front
  SECONDARY_SHARE = 0.35    # additional people add less than the top name (they share films)
  GENRE_CLAMP = (0.8..1.25)

  Member = Struct.new(:person, :role, :fee_usd, keyword_init: true)

  def initialize(project, members: nil)
    @project = project
    @members = members || project.package_members.includes(:person).map do |pm|
      Member.new(person: pm.person, role: pm.role, fee_usd: pm.effective_fee_usd)
    end
  end

  def call
    territories = Territory.all.to_a
    values = @members.to_h { |m| [m.person.id, PersonValue.new(m.person)] }
    genre_mult = genre_multiplier

    member_rows = @members.map { |m| member_row(m, values[m.person.id], genre_mult) }
    territory_rows = territories.map { |t| territory_row(t, values, genre_mult) }

    presales = territory_rows.sum { |r| r[:estimate_usd] }
    fees = member_rows.sum { |r| r[:fee_usd] }
    coverage = @project.budget_usd.to_i.positive? ? (presales.to_f / @project.budget_usd).round(2) : nil
    risk = risk_assessment(member_rows, presales, coverage)

    {
      project_id: @project.id,
      genre_multiplier: genre_mult.round(2),
      members: member_rows,
      territories: territory_rows,
      totals: { expected_presales_usd: presales, total_fees_usd: fees, budget_usd: @project.budget_usd,
                budget_coverage: coverage },
      risk: risk,
      disclaimer: "Estimates are heuristic and based on the data loaded in this system. Use them to inform, not replace, your own judgement."
    }
  end

  private

  def member_row(member, value, genre_mult)
    expected = (value.by_territory.values.sum * PRESALE_RATIO * genre_mult).round
    fee = member.fee_usd.to_i
    ratio = fee.positive? ? (expected.to_f / fee).round(2) : nil
    top = value.by_territory.max_by(3) { |_, v| v }.map do |tid, v|
      { territory: territory_names[tid], estimate_usd: (v * PRESALE_RATIO * genre_mult).round }
    end
    {
      person_id: member.person.id, name: member.person.name, kind: member.person.kind, role: member.role,
      fee_usd: fee, expected_sales_usd: expected, value_ratio: ratio, verdict: verdict(ratio, value.film_count),
      film_count: value.film_count, top_territories: top
    }
  end

  def territory_row(territory, values, genre_mult)
    contribs = @members.filter_map do |m|
      v = values[m.person.id].by_territory[territory.id]
      [m.person.name, (v * PRESALE_RATIO * genre_mult).round] if v&.positive?
    end.sort_by { |_, est| -est }
    estimate = contribs.empty? ? 0 : contribs.first[1] + (SECONDARY_SHARE * contribs.drop(1).sum { |_, est| est }).round
    { territory_id: territory.id, territory: territory.name, code: territory.code, kind: territory.kind,
      estimate_usd: estimate, contributors: contribs.first(2).map { |n, est| { name: n, estimate_usd: est } } }
  end

  def verdict(ratio, film_count)
    return "no_data" if film_count.zero?
    return "unknown" if ratio.nil?
    return "strong" if ratio >= 2.0
    return "fair" if ratio >= 1.0
    "weak"
  end

  def genre_multiplier
    return 1.0 if @project.genre.blank?
    genre_avg = average_worldwide(Film.where(genre: @project.genre))
    overall = average_worldwide(Film.all)
    return 1.0 if genre_avg.nil? || overall.nil? || overall.zero?
    (genre_avg / overall).clamp(GENRE_CLAMP.min, GENRE_CLAMP.max)
  end

  def average_worldwide(films)
    sums = TerritoryPerformance.where(film_id: films.select(:id)).group(:film_id).sum(:gross_usd).values
    sums.empty? ? nil : sums.sum.to_f / sums.size
  end

  def territory_names
    @territory_names ||= Territory.pluck(:id, :name).to_h
  end

  def risk_assessment(member_rows, presales, coverage)
    points = 0
    notes = []
    people = @members.map(&:person)

    people.each do |p|
      if p.controversy_level >= 2
        points += 15
        notes << "#{p.name}: significant public-persona concerns (level #{p.controversy_level})."
      elsif p.controversy_level == 1
        points += 5
        notes << "#{p.name}: minor public-persona concerns."
      end
      opposite = { "left" => "right", "right" => "left" }[@project.political_leaning]
      if opposite && p.politics_lean == opposite
        points += 12
        notes << "#{p.name}: publicly #{p.politics_lean}-leaning, project is #{@project.political_leaning}-leaning."
      end
    end

    if coverage
      step = if coverage < 0.3 then 30 elsif coverage < 0.5 then 20 elsif coverage < 0.7 then 10 else 0 end
      points += step
      notes << "Estimated presales cover #{(coverage * 100).round}% of the budget." if step.positive?
    end

    member_rows.each do |r|
      if r[:verdict] == "weak"
        points += 8
        notes << "#{r[:name]}: fee is higher than expected sales value."
      elsif r[:verdict] == "no_data"
        points += 5
        notes << "#{r[:name]}: no performance data loaded, so no value estimate."
      end
    end

    top = member_rows.max_by { |r| r[:expected_sales_usd] }
    if top && member_rows.size > 1 && presales.positive? && top[:expected_sales_usd].to_f / presales > 0.6
      points += 10
      notes << "Package depends heavily on #{top[:name]} for sales value."
    end

    score = [points, 100].min
    level = score < 25 ? "low" : score < 50 ? "medium" : "high"
    { score: score, level: level, notes: notes }
  end
end
