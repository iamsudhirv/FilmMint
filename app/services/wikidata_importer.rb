require "net/http"
require "json"

# Imports REAL film data from Wikidata (CC0, designed for bulk/SPARQL use - no scraping, no API key):
# title, year, language, genre, budget and worldwide box office (when given in USD), director and cast.
#
# Wikidata has no territory-by-territory box office, no fees and no cast billing order, so imported films
# only carry a worldwide total. They are tagged source "wikidata" and never mixed up with the demo data.
class WikidataImporter
  ENDPOINT = URI("https://query.wikidata.org/sparql")
  USER_AGENT = "FilmMint/0.1 (ani.ai@aniintegrated.com)"

  # industry => how to find its films on Wikidata
  INDUSTRIES = {
    "hollywood" => { filter: "?film wdt:P495 wd:Q30.", limit: 20, require_gross: true },
    "bollywood" => { filter: "?film wdt:P495 wd:Q668.", limit: 20 },
    "french" => { filter: "?film wdt:P495 wd:Q142.", limit: 15 },
    "japanese" => { filter: "?film wdt:P495 wd:Q17.", limit: 15 },
    "pakistani" => { filter: "?film wdt:P495 wd:Q843.", limit: 12 },
    "bhojpuri" => { filter: "?film wdt:P364 wd:Q33268.", limit: 10 },
    "portuguese" => { filter: "?film wdt:P495 wd:Q45.", limit: 12 }
  }.freeze

  MAX_ACTORS_PER_FILM = 4

  def initialize(industries: INDUSTRIES.keys, logger: Rails.logger)
    @industries = industries
    @logger = logger
  end

  def call
    @industries.each_with_object({}) do |industry, summary|
      rows = film_rows(industry)
      films = rows.filter_map { |row| upsert_film(industry, row) }
      attach_people(industry, films)
      summary[industry] = films.size
    rescue StandardError => e
      @logger.error("Wikidata import failed for #{industry}: #{e.class}: #{e.message}")
      summary[industry] = "failed (#{e.message.truncate(80)})"
    end
  end

  private

  CANDIDATES = 50 # most-notable films fetched per industry before filtering/trimming

  # Two light queries instead of one heavy one: (1) most notable film ids, (2) details for just those.
  def film_rows(industry)
    cfg = INDUSTRIES.fetch(industry)
    needs_gross = cfg[:require_gross] ? "?film wdt:P2142 ?anyGross." : ""
    ids = sparql(<<~SPARQL).map { |r| "wd:#{id_of(r['film']['value'])}" }
      SELECT ?film ?links WHERE {
        ?film wdt:P31 wd:Q11424; wikibase:sitelinks ?links.
        #{cfg[:filter]}
        #{needs_gross}
      } ORDER BY DESC(?links) LIMIT #{CANDIDATES}
    SPARQL
    return [] if ids.empty?

    rows = sparql(<<~SPARQL)
      SELECT ?film (SAMPLE(?t) AS ?title) (MIN(?y) AS ?year) (MAX(?g) AS ?gross) (MAX(?b) AS ?budget)
             (SAMPLE(?lang) AS ?language) (SAMPLE(?gen) AS ?genre) (MAX(?l) AS ?links) WHERE {
        VALUES ?film { #{ids.join(' ')} }
        ?film wikibase:sitelinks ?l; wdt:P577 ?date; rdfs:label ?t FILTER(lang(?t) = "en")
        BIND(YEAR(?date) AS ?y)
        OPTIONAL { #{gross_pattern} }
        OPTIONAL { ?film p:P2130/psv:P2130 ?bn. ?bn wikibase:quantityAmount ?b; wikibase:quantityUnit wd:Q4917. }
        OPTIONAL { ?film wdt:P364 ?lg. ?lg rdfs:label ?lang FILTER(lang(?lang) = "en") }
        OPTIONAL { ?film wdt:P136 ?gn. ?gn rdfs:label ?gen FILTER(lang(?gen) = "en") }
      } GROUP BY ?film
    SPARQL
    rows = rows.select { |r| r["year"]["value"].to_i >= 1985 }
    rows = rows.select { |r| r["gross"] } if cfg[:require_gross]
    rows.sort_by { |r| -r["links"]["value"].to_i }.first(cfg[:limit])
  end

  def gross_pattern
    "?film p:P2142/psv:P2142 ?gp. ?gp wikibase:quantityAmount ?g; wikibase:quantityUnit wd:Q4917."
  end

  def upsert_film(industry, row)
    qid = id_of(row["film"]["value"])
    film = Film.find_or_initialize_by(wikidata_id: qid)
    film.assign_attributes(
      title: row["title"]["value"], year: row.dig("year", "value")&.to_i, industry: industry, source: "wikidata",
      language: row.dig("language", "value"), genre: row.dig("genre", "value")&.sub(/ film\z/i, ""),
      budget_usd: positive(row.dig("budget", "value")), worldwide_gross_usd: positive(row.dig("gross", "value"))
    )
    film.save!
    film
  end

  def attach_people(industry, films)
    return if films.empty?
    ids = films.map { |f| "wd:#{f.wikidata_id}" }.join(" ")
    query = <<~SPARQL
      SELECT ?film ?person ?personLabel ?role WHERE {
        VALUES ?film { #{ids} }
        { ?film wdt:P57 ?person. BIND("director" AS ?role) } UNION { ?film wdt:P161 ?person. BIND("actor" AS ?role) }
        SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
      }
    SPARQL
    by_film = sparql(query).group_by { |r| id_of(r["film"]["value"]) }
    films.each do |film|
      rows = by_film.fetch(film.wikidata_id, [])
      directors = rows.select { |r| r["role"]["value"] == "director" }.first(2)
      actors = rows.select { |r| r["role"]["value"] == "actor" }.first(MAX_ACTORS_PER_FILM)
      (directors + actors).reject { |r| r["personLabel"]["value"].match?(/\AQ\d+\z/) }.each_with_index do |r, i|
        person = Person.find_or_initialize_by(wikidata_id: id_of(r["person"]["value"]))
        person.assign_attributes(name: r["personLabel"]["value"], kind: r["role"]["value"], industry: industry, source: "wikidata") if person.new_record?
        person.save!
        Credit.find_or_create_by!(person: person, film: film, role: r["role"]["value"]) { |c| c.billing_order = i + 1 }
      end
    end
  end

  # Wikidata aggregates return 0 when a value is missing; 0 would be misread as a real figure.
  def positive(value)
    n = value&.to_f&.round
    n&.positive? ? n : nil
  end

  def id_of(uri) = uri.split("/").last

  def sparql(query)
    sleep 1 # be polite to the public endpoint
    uri = ENDPOINT.dup
    uri.query = URI.encode_www_form(query: query, format: "json")
    req = Net::HTTP::Get.new(uri, "User-Agent" => USER_AGENT, "Accept" => "application/sparql-results+json")
    res = nil
    2.times do
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 70) { |http| http.request(req) }
      break if res.is_a?(Net::HTTPSuccess)
      sleep 5
    end
    raise "Wikidata HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body).dig("results", "bindings")
  end
end
