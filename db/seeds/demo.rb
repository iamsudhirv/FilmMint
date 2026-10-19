# DEMO DATA: every person, film and number below is fictional and exists only so the
# app can be tried locally. Replace with imported real data (TMDB, Wikidata, ...) later.
M = 1_000_000

TERRITORIES = [
  ["United States", "US"], ["United Kingdom", "UK"], ["France", "FR"], ["Germany", "DE"],
  ["Italy", "IT"], ["Spain", "ES"], ["Japan", "JP"], ["India", "IN"],
  ["Latin America", "LATAM", "group"], ["Balkans", "BALKANS", "group"],
  ["Russian-speaking", "RU", "group"], ["Australia / NZ", "ANZ"]
].each_with_index.map do |(name, code, kind), i|
  Territory.find_or_create_by!(code: code) { |t| t.assign_attributes(name: name, kind: kind || "country", position: i) }
end

def person(name, kind, **attrs)
  Person.find_or_initialize_by(name: name).tap { |p| p.update!(attrs.merge(kind: kind)) }
end

me = person("You (Demo Producer)", "producer", is_self: true, bio: "This is you. Connection paths start here.")
oliver = person("Oliver Grant", "producer", nationality: "US", bio: "Independent producer.")
dana = person("Dana Cho", "sales_agent", nationality: "US", bio: "International sales agent, strong in Asia.")
rita = person("Rita Stein", "agent", nationality: "US", bio: "Talent agent.")
henrik = person("Henrik Aalto", "sales_agent", nationality: "FI", bio: "European sales, Germany and Nordics.")
carlos = person("Carlos Mendes", "agent", nationality: "BR", bio: "Talent manager, Latin America.")
meera = person("Meera Joshi", "producer", nationality: "IN", bio: "Mumbai-based producer.")

marcus = person("Marcus Hale", "actor", nationality: "US", fee_usd: 3_500_000, politics_lean: "center",
                social_followers: 12_000_000, social_engagement_pct: 2.1, controversy_level: 0)
elena = person("Elena Voss", "actor", nationality: "DE", fee_usd: 1_200_000, politics_lean: "left",
               social_followers: 2_400_000, social_engagement_pct: 4.8, controversy_level: 0,
               persona_notes: "Very popular in German-speaking markets.")
ravi = person("Ravi Kapoor", "actor", nationality: "IN", fee_usd: 900_000, politics_lean: "center",
              social_followers: 9_500_000, social_engagement_pct: 3.9, controversy_level: 0)
camille = person("Camille Laurent", "actor", nationality: "FR", fee_usd: 800_000, politics_lean: "left",
                 social_followers: 1_800_000, social_engagement_pct: 3.2, controversy_level: 0)
diego = person("Diego Salazar", "actor", nationality: "MX", fee_usd: 1_000_000, politics_lean: "center",
               social_followers: 6_200_000, social_engagement_pct: 4.4, controversy_level: 1,
               persona_notes: "One minor press controversy in 2023.")
hana = person("Hana Mori", "actor", nationality: "JP", fee_usd: 700_000, politics_lean: "center",
              social_followers: 3_100_000, social_engagement_pct: 3.0, controversy_level: 0)
jack = person("Jack Brennan", "actor", nationality: "UK", fee_usd: 2_000_000, politics_lean: "left",
              social_followers: 1_100_000, social_engagement_pct: 1.4, controversy_level: 2,
              persona_notes: "Public dispute with a previous studio; some bookers hesitant.")
sofia = person("Sofia Marin", "actor", nationality: "ES", fee_usd: 400_000, politics_lean: "center",
               social_followers: 2_700_000, social_engagement_pct: 5.5, controversy_level: 0)
tom = person("Tom Reyes", "actor", nationality: "US", fee_usd: 4_000_000, politics_lean: "right",
             social_followers: 5_400_000, social_engagement_pct: 1.2, controversy_level: 1,
             persona_notes: "Outspoken political commentary online.")
nina = person("Nina Petrova", "actor", nationality: "RU", fee_usd: 600_000, politics_lean: "center",
              social_followers: 1_500_000, social_engagement_pct: 3.6, controversy_level: 0)
alan = person("Alan Whitcombe", "director", nationality: "UK", fee_usd: 1_500_000, politics_lean: "center",
              social_followers: 300_000, social_engagement_pct: 0.9, controversy_level: 0)
priya = person("Priya Nair", "director", nationality: "IN", fee_usd: 600_000, politics_lean: "left",
               social_followers: 450_000, social_engagement_pct: 2.2, controversy_level: 0)
lukas = person("Lukas Brandt", "director", nationality: "DE", fee_usd: 800_000, politics_lean: "center",
               social_followers: 200_000, social_engagement_pct: 1.1, controversy_level: 0)
ines = person("Ines Duarte", "cinematographer", nationality: "PT", fee_usd: 250_000, politics_lean: "center",
              controversy_level: 0)

# [title, year, genre, budget $M, gross $M in territory order, cast/crew [person, role, billing]]
# Territory order: US UK FR DE IT ES JP IN LATAM BALKANS RU ANZ
FILMS = [
  ["Iron Meridian", 2022, "action", 90, [85, 20, 12, 15, 8, 9, 14, 6, 18, 5, 9, 7], [[marcus, "actor", 1], [tom, "actor", 2]]],
  ["Last Train to Lyon", 2021, "thriller", 25, [14, 8, 22, 7, 6, 5, 3, 1, 3, 2, 2, 3], [[camille, "actor", 1], [jack, "actor", 2]]],
  ["Winter Sonata Berlin", 2023, "drama", 18, [6, 7, 9, 31, 8, 6, 4, 1, 3, 4, 5, 3], [[elena, "actor", 1], [lukas, "director", 1]]],
  ["Monsoon Hearts", 2022, "romance", 12, [3, 4, 2, 2, 1, 1, 2, 38, 2, 1, 1, 2], [[ravi, "actor", 1], [priya, "director", 1]]],
  ["Fuego del Sur", 2023, "drama", 15, [12, 3, 4, 3, 6, 18, 1, 1, 34, 2, 2, 2], [[diego, "actor", 1], [sofia, "actor", 3]]],
  ["Tokyo Static", 2020, "sci-fi", 40, [22, 9, 8, 7, 5, 4, 48, 3, 5, 2, 3, 5], [[hana, "actor", 1], [jack, "actor", 3]]],
  ["The Harbour Men", 2019, "crime", 30, [18, 32, 6, 8, 5, 4, 2, 2, 4, 3, 4, 10], [[jack, "actor", 1], [alan, "director", 1]]],
  ["Night of Knives", 2023, "horror", 8, [24, 6, 5, 6, 4, 5, 4, 2, 7, 2, 3, 3], [[sofia, "actor", 1], [tom, "actor", 3]]],
  ["Steel Horizon", 2024, "action", 120, [95, 28, 16, 20, 11, 12, 18, 22, 24, 7, 14, 12], [[marcus, "actor", 1], [elena, "actor", 2], [ravi, "actor", 3]]],
  ["Quiet Rivers", 2021, "drama", 10, [5, 6, 7, 9, 5, 4, 3, 1, 2, 3, 2, 2], [[elena, "actor", 1], [camille, "actor", 2], [ines, "cinematographer", 1]]],
  ["Laugh Track", 2022, "comedy", 20, [48, 9, 3, 4, 2, 3, 1, 2, 6, 1, 2, 6], [[tom, "actor", 1], [sofia, "actor", 2]]],
  ["Cold Steppe", 2020, "thriller", 22, [8, 5, 4, 6, 3, 3, 2, 1, 2, 7, 38, 2], [[nina, "actor", 1], [jack, "actor", 2]]],
  ["Echoes of Kyoto", 2024, "drama", 14, [4, 3, 4, 3, 2, 2, 21, 1, 1, 1, 1, 2], [[hana, "actor", 1], [alan, "director", 1], [ines, "cinematographer", 1]]],
  ["Carnival Heist", 2023, "crime", 35, [30, 8, 7, 6, 5, 14, 3, 4, 32, 3, 4, 5], [[diego, "actor", 1], [marcus, "actor", 2], [camille, "actor", 4]]]
]

FILMS.each do |title, year, genre, budget, grosses, crew|
  film = Film.find_or_create_by!(title: title) { |f| f.assign_attributes(year: year, genre: genre, budget_usd: budget * M) }
  TERRITORIES.zip(grosses).each do |territory, gross|
    TerritoryPerformance.find_or_create_by!(film: film, territory: territory) { |tp| tp.gross_usd = gross * M }
  end
  crew.each do |p, role, billing|
    Credit.find_or_create_by!(person: p, film: film, role: role) { |c| c.billing_order = billing }
  end
end

# Who knows whom (undirected): [a, b, strength 1-5, note]
[
  [me, oliver, 5, "Co-produced two films"], [me, dana, 4, "Sold my last film"],
  [oliver, rita, 4, "Rita reps Marcus Hale"], [rita, marcus, 5, "Agent"], [rita, tom, 4, "Agent"],
  [dana, henrik, 3, "Co-sell in Europe"], [henrik, elena, 4, "Sales relationship"], [henrik, lukas, 3, nil],
  [dana, meera, 3, "Met at Cannes"], [meera, ravi, 5, "Produced his hits"], [meera, priya, 4, nil],
  [oliver, carlos, 2, "Introduced at TIFF"], [carlos, diego, 5, "Manager"], [carlos, sofia, 3, nil],
  [henrik, camille, 2, nil], [dana, hana, 3, "Sold Tokyo Static"], [hana, alan, 2, nil],
  [rita, jack, 3, "Former client"], [jack, nina, 2, nil], [alan, ines, 3, nil]
].each do |a, b, s, note|
  next if Connection.exists?(person: a, other_person: b) || Connection.exists?(person: b, other_person: a)
  Connection.create!(person: a, other_person: b, strength: s, note: note)
end

demo = Project.find_or_create_by!(title: "Midnight Ledger") do |p|
  p.assign_attributes(genre: "thriller", budget_usd: 18 * M, political_leaning: "left",
                      logline: "A forensic accountant uncovers a laundering ring tied to a film festival.")
end
[[elena, "actor"], [alan, "director"], [tom, "actor"]].each do |person, role|
  PackageMember.find_or_create_by!(project: demo, person: person) { |pm| pm.role = role }
end

puts "Demo: #{Person.count} people, #{Film.count} films, #{Territory.count} territories, #{Connection.count} connections, #{Project.count} project(s)"

# A few more fictional projects so the dashboard pipeline has something in every stage.
[
  ["Harbour Lights", "crime", 30, "none", "financing", [[alan, "director"], [jack, "actor"], [marcus, "actor"]]],
  ["Paper Moons", "romance", 9, "left", "pre_production", [[ravi, "actor"], [priya, "director"]]],
  ["Salt and Iron", "action", 60, "none", "production", [[marcus, "actor"], [elena, "actor"], [alan, "director"]]],
  ["Low Tide", "drama", 6, "none", "post", [[hana, "actor"], [ines, "cinematographer"]]]
].each do |title, genre, budget, leaning, status, crew|
  project = Project.find_or_create_by!(title: title) do |p|
    p.assign_attributes(genre: genre, budget_usd: budget * M, political_leaning: leaning, status: status)
  end
  crew.each { |person, role| PackageMember.find_or_create_by!(project: project, person: person) { |pm| pm.role = role } }
end
puts "Demo projects: #{Project.count}"
