# Shortest introduction path between two people.
#
# The graph has two kinds of links (both undirected):
#   * explicit connections someone recorded ("I know her", strength 1-5)
#   * "worked together": two people credited on the same film (derived from real Wikidata credits
#     as well as demo credits). Strength 3.
# An explicit connection wins when both exist. Breadth-first search in memory is fine for an MVP;
# move to a recursive SQL query or a graph store when the network grows large.
class ConnectionPath
  CREDIT_STRENGTH = 3

  Graph = Struct.new(:adjacency, :info)

  def initialize(from:, to:)
    @from = from
    @to = to
  end

  def call
    return result([@from.id]) if @from.id == @to.id

    parents = { @from.id => nil }
    queue = [@from.id]
    until queue.empty?
      current = queue.shift
      graph.adjacency.fetch(current, []).each do |neighbour|
        next if parents.key?(neighbour)
        parents[neighbour] = current
        return result(build_path(parents, neighbour)) if neighbour == @to.id
        queue << neighbour
      end
    end
    nil
  end

  def self.build_graph
    adjacency = Hash.new { |h, k| h[k] = [] }
    info = {}
    link = lambda do |a, b, strength, note|
      key = [a, b].sort
      next if info.key?(key)
      info[key] = { strength: strength, note: note }
      adjacency[a] << b
      adjacency[b] << a
    end

    Connection.pluck(:person_id, :other_person_id, :strength, :note).each { |a, b, s, n| link.(a, b, s, n) }

    films = Film.where(id: Credit.select(:film_id)).pluck(:id, :title, :year).to_h { |id, t, y| [id, y ? "#{t} (#{y})" : t] }
    Credit.pluck(:film_id, :person_id).group_by(&:first).each do |film_id, rows|
      rows.map(&:last).uniq.combination(2) { |a, b| link.(a, b, CREDIT_STRENGTH, "Worked together on #{films[film_id]}") }
    end
    Graph.new(adjacency, info)
  end

  private

  def graph
    @graph ||= self.class.build_graph
  end

  def build_path(parents, last)
    ids = []
    node = last
    while node
      ids.unshift(node)
      node = parents[node]
    end
    ids
  end

  def result(ids)
    people = Person.where(id: ids).index_by(&:id)
    links = ids.each_cons(2).map { |a, b| graph.info[[a, b].sort] }
    {
      degrees: ids.size - 1,
      steps: links.map { |l| l[:strength] },
      notes: links.map { |l| l[:note] },
      path: ids.map { |id| { id: id, name: people[id].name, kind: people[id].kind, source: people[id].source } }
    }
  end
end
