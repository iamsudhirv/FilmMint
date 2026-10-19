require "test_helper"

class ConnectionPathTest < ActiveSupport::TestCase
  setup do
    @me, @a, @b, @c, @island = %w[Me A B C Island].map { |n| Person.create!(name: n, kind: "producer") }
    Connection.create!(person: @me, other_person: @a, strength: 5)
    Connection.create!(person: @b, other_person: @a, strength: 3) # stored in reverse direction on purpose
    Connection.create!(person: @b, other_person: @c, strength: 4)
  end

  test "finds shortest path regardless of edge direction" do
    result = ConnectionPath.new(from: @me, to: @c).call
    assert_equal 3, result[:degrees]
    assert_equal %w[Me A B C], result[:path].map { |p| p[:name] }
    assert_equal [5, 3, 4], result[:steps]
  end

  test "people credited on the same film are linked, and explicit links keep their own note" do
    film = Film.create!(title: "Shared Film", year: 2020)
    Credit.create!(person: @c, film: film, role: "actor")
    Credit.create!(person: @island, film: film, role: "director")
    result = ConnectionPath.new(from: @me, to: @island).call
    assert_equal 4, result[:degrees]
    assert_equal "Worked together on Shared Film (2020)", result[:notes].last
    assert_nil result[:notes].first
  end

  test "returns nil when unreachable" do
    assert_nil ConnectionPath.new(from: @me, to: @island).call
  end
end
