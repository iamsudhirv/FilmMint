require "test_helper"

class PackageValuationTest < ActiveSupport::TestCase
  setup do
    @us = Territory.create!(name: "United States", code: "US", position: 0)
    @de = Territory.create!(name: "Germany", code: "DE", position: 1)
    film = Film.create!(title: "Test Film", genre: "drama", year: 2023)
    TerritoryPerformance.create!(film: film, territory: @us, gross_usd: 10_000_000)
    TerritoryPerformance.create!(film: film, territory: @de, gross_usd: 30_000_000)
    @star = Person.create!(name: "Star", kind: "actor", fee_usd: 1_000_000)
    @newcomer = Person.create!(name: "Newcomer", kind: "actor", fee_usd: 500_000)
    Credit.create!(person: @star, film: film, role: "actor", billing_order: 1)
    @project = Project.create!(title: "P", genre: "drama", budget_usd: 10_000_000)
  end

  test "value comes from credited films by territory" do
    assert_equal({ @us.id => 10_000_000, @de.id => 30_000_000 }, PersonValue.new(@star).by_territory)
  end

  test "supporting billing is worth less than lead billing" do
    film = Film.first
    support = Person.create!(name: "Support", kind: "actor")
    Credit.create!(person: support, film: film, role: "actor", billing_order: 3)
    assert_equal 5_000_000, PersonValue.new(support).by_territory[@us.id]
  end

  test "valuation estimates presales, fee return and flags people without data" do
    PackageMember.create!(project: @project, person: @star, role: "actor")
    PackageMember.create!(project: @project, person: @newcomer, role: "actor")
    result = PackageValuation.new(@project).call

    star = result[:members].find { |m| m[:name] == "Star" }
    assert_equal 2_000_000, star[:expected_sales_usd] # 40M * 5%
    assert_equal "strong", star[:verdict]
    assert_equal "no_data", result[:members].find { |m| m[:name] == "Newcomer" }[:verdict]
    assert_equal 2_000_000, result[:totals][:expected_presales_usd]
    assert_includes result[:risk][:notes].join, "no performance data"
  end

  test "politics mismatch and controversy raise risk" do
    @project.update!(political_leaning: "left")
    @star.update!(politics_lean: "right", controversy_level: 2)
    PackageMember.create!(project: @project, person: @star, role: "actor")
    notes = PackageValuation.new(@project).call[:risk][:notes].join(" ")
    assert_match(/right-leaning/, notes)
    assert_match(/public-persona/, notes)
  end
end
