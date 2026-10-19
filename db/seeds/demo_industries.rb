# DEMO DATA (fictional): adds industries (Bollywood incl. regional languages, French, Japanese,
# Pakistani, Bhojpuri, Portuguese), three more territories, and people/films/network for each.
M = 1_000_000 unless defined?(M)

%w[PK:Pakistan PT:Portugal ME:Middle\ East].each_with_index do |pair, i|
  code, name = pair.split(":")
  Territory.find_or_create_by!(code: code) { |t| t.assign_attributes(name: name, kind: "country", position: 12 + i) }
end
EXTRA = %w[PK PT ME].map { |c| Territory.find_by!(code: c) }

def person(name, kind, industry, **attrs)
  Person.find_or_initialize_by(name: name).tap { |p| p.update!(attrs.merge(kind: kind, industry: industry)) }
end
P = ->(name) { Person.find_by!(name: name) }

# --- existing demo people: set their industry ------------------------------------------
{ "Ravi Kapoor" => "bollywood", "Priya Nair" => "bollywood", "Camille Laurent" => "french",
  "Hana Mori" => "japanese", "Meera Joshi" => "bollywood", "Dana Cho" => "hollywood" }.each do |n, ind|
  P.(n).update!(industry: ind)
end

# --- new people -------------------------------------------------------------------------
person("Maya Collins", "actor", "hollywood", nationality: "US", fee_usd: 1_800_000, politics_lean: "left", social_followers: 8_000_000, social_engagement_pct: 3.4)
person("Daniel Okafor", "actor", "hollywood", nationality: "UK", fee_usd: 1_300_000, politics_lean: "center", social_followers: 3_900_000, social_engagement_pct: 2.7)

person("Aarav Malhotra", "actor", "bollywood", nationality: "IN", fee_usd: 2_200_000, politics_lean: "center", social_followers: 25_000_000, social_engagement_pct: 3.1, controversy_level: 1, persona_notes: "Brief social-media row in 2024.")
person("Tara Bhatt", "actor", "bollywood", nationality: "IN", fee_usd: 1_400_000, politics_lean: "center", social_followers: 18_000_000, social_engagement_pct: 4.2)
person("Vikram Reddy", "actor", "bollywood", nationality: "IN", fee_usd: 1_800_000, politics_lean: "center", social_followers: 14_000_000, social_engagement_pct: 5.0, persona_notes: "Telugu-language star, huge in the south.")
person("Karthik Subramanian", "actor", "bollywood", nationality: "IN", fee_usd: 1_100_000, politics_lean: "left", social_followers: 9_000_000, social_engagement_pct: 4.6, persona_notes: "Tamil-language star.")
person("Meenal Kurup", "actor", "bollywood", nationality: "IN", fee_usd: 400_000, politics_lean: "left", social_followers: 1_900_000, social_engagement_pct: 3.8, persona_notes: "Malayalam-language actress, festival favourite.")
person("Gurpreet Sandhu", "actor", "bollywood", nationality: "IN", fee_usd: 700_000, politics_lean: "center", social_followers: 11_000_000, social_engagement_pct: 4.9, persona_notes: "Punjabi-language actor and singer; strong diaspora pull in UK/Canada/Australia.")
person("Rohan Deshpande", "director", "bollywood", nationality: "IN", fee_usd: 900_000, politics_lean: "center", social_followers: 700_000, social_engagement_pct: 1.5)
person("Sunita Iyer", "director", "bollywood", nationality: "IN", fee_usd: 500_000, politics_lean: "left", social_followers: 350_000, social_engagement_pct: 1.9)

person("Étienne Moreau", "actor", "french", nationality: "FR", fee_usd: 900_000, politics_lean: "left", social_followers: 1_600_000, social_engagement_pct: 2.5)
person("Léa Fontaine", "actor", "french", nationality: "FR", fee_usd: 700_000, politics_lean: "center", social_followers: 2_200_000, social_engagement_pct: 3.3)
person("Julien Marchetti", "director", "french", nationality: "FR", fee_usd: 600_000, politics_lean: "left", social_followers: 250_000, social_engagement_pct: 1.2)

person("Kenji Arai", "actor", "japanese", nationality: "JP", fee_usd: 800_000, politics_lean: "center", social_followers: 2_800_000, social_engagement_pct: 2.9)
person("Yui Takeda", "actor", "japanese", nationality: "JP", fee_usd: 600_000, politics_lean: "center", social_followers: 3_500_000, social_engagement_pct: 3.6)
person("Hiroshi Mizuno", "director", "japanese", nationality: "JP", fee_usd: 700_000, politics_lean: "center", social_followers: 400_000, social_engagement_pct: 1.0)

person("Zain Chaudhry", "actor", "pakistani", nationality: "PK", fee_usd: 300_000, politics_lean: "center", social_followers: 7_000_000, social_engagement_pct: 4.1)
person("Hira Siddiqui", "actor", "pakistani", nationality: "PK", fee_usd: 250_000, politics_lean: "center", social_followers: 5_500_000, social_engagement_pct: 4.7)
person("Omer Nadeem", "director", "pakistani", nationality: "PK", fee_usd: 200_000, politics_lean: "center", social_followers: 300_000, social_engagement_pct: 1.8)
person("Sana Mirza", "producer", "pakistani", nationality: "PK", bio: "Karachi-based producer.")

person("Ajay Pandey", "actor", "bhojpuri", nationality: "IN", fee_usd: 180_000, politics_lean: "center", social_followers: 6_000_000, social_engagement_pct: 6.2)
person("Rani Kushwaha", "actor", "bhojpuri", nationality: "IN", fee_usd: 120_000, politics_lean: "center", social_followers: 4_200_000, social_engagement_pct: 6.8)
person("Mukesh Chaubey", "director", "bhojpuri", nationality: "IN", fee_usd: 80_000, politics_lean: "center", social_followers: 150_000, social_engagement_pct: 2.0)
person("Raghav Dubey", "producer", "bhojpuri", nationality: "IN", bio: "Patna-based producer.")

person("Tiago Almeida", "actor", "portuguese", nationality: "PT", fee_usd: 300_000, politics_lean: "left", social_followers: 900_000, social_engagement_pct: 3.0)
person("Inês Carvalho", "actor", "portuguese", nationality: "PT", fee_usd: 350_000, politics_lean: "center", social_followers: 1_300_000, social_engagement_pct: 3.7)
person("Beatriz Lobo", "actor", "portuguese", nationality: "BR", fee_usd: 250_000, politics_lean: "center", social_followers: 2_000_000, social_engagement_pct: 4.5, persona_notes: "Brazilian actress who works in Portugal; bridges both markets.")
person("Rui Teixeira", "director", "portuguese", nationality: "PT", fee_usd: 250_000, politics_lean: "left", social_followers: 120_000, social_engagement_pct: 1.4)

person("Claire Dubois", "sales_agent", "french", nationality: "FR", bio: "Paris-based international sales agent.")

# --- films: [title, year, industry, language, genre, budget $M, grosses, crew] -----------------
# Gross order: US UK FR DE IT ES JP IN LATAM BALKANS RU ANZ PK PT ME
# Existing demo films only get the three new territories appended (plus an industry tag).
EXISTING = {
  "Iron Meridian" => ["hollywood", "English", [2, 3, 14]], "Last Train to Lyon" => ["french", "French", [0.5, 4, 2]],
  "Winter Sonata Berlin" => ["hollywood", "German", [0.3, 2, 2]], "Monsoon Hearts" => ["bollywood", "Hindi", [0.2, 0.5, 9]],
  "Fuego del Sur" => ["hollywood", "Spanish", [0.1, 5, 1]], "Tokyo Static" => ["japanese", "Japanese", [0.2, 1, 2]],
  "The Harbour Men" => ["hollywood", "English", [0.5, 2, 4]], "Night of Knives" => ["hollywood", "English", [0.3, 1, 2]],
  "Steel Horizon" => ["hollywood", "English", [1.5, 5, 22]], "Quiet Rivers" => ["french", "French", [0.1, 2, 1]],
  "Laugh Track" => ["hollywood", "English", [0.3, 1, 3]], "Cold Steppe" => ["hollywood", "Russian", [0.2, 1, 2]],
  "Echoes of Kyoto" => ["japanese", "Japanese", [0.1, 0.5, 1]], "Carnival Heist" => ["hollywood", "English", [0.4, 9, 3]]
}
EXISTING.each do |title, (industry, language, extra)|
  film = Film.find_by!(title: title)
  film.update!(industry: industry, language: language)
  EXTRA.zip(extra).each { |t, g| TerritoryPerformance.find_or_create_by!(film: film, territory: t) { |tp| tp.gross_usd = (g * M).to_i } }
end

NEW_FILMS = [
  ["Glass Frontier", 2023, "hollywood", "English", "thriller", 45, [38, 12, 6, 7, 5, 5, 6, 5, 9, 3, 4, 6, 1, 2, 15], [["Maya Collins", "actor", 1], ["Daniel Okafor", "actor", 2], ["Alan Whitcombe", "director", 1]]],
  ["Last Summer in Maine", 2022, "hollywood", "English", "romance", 14, [30, 8, 3, 4, 2, 3, 2, 2, 5, 1, 1, 5, 0.2, 1, 3], [["Maya Collins", "actor", 1]]],

  ["Raja's Wedding", 2023, "bollywood", "Hindi", "comedy", 15, [6, 5, 1, 1, 0.5, 0.5, 0.5, 48, 1, 0.5, 2, 3, 0.3, 0.2, 14], [["Aarav Malhotra", "actor", 1], ["Tara Bhatt", "actor", 2], ["Rohan Deshpande", "director", 1]]],
  ["Midnight Express Delhi", 2024, "bollywood", "Hindi", "action", 25, [8, 6, 1, 2, 1, 1, 1, 62, 1, 1, 3, 5, 0.2, 0.2, 18], [["Aarav Malhotra", "actor", 1], ["Ravi Kapoor", "actor", 3], ["Rohan Deshpande", "director", 1]]],
  ["Chennai Thunder", 2022, "bollywood", "Tamil", "action", 18, [3, 4, 0.5, 0.5, 0.3, 0.3, 3, 40, 0.5, 0.3, 0.5, 2, 0.1, 0.1, 10], [["Karthik Subramanian", "actor", 1], ["Sunita Iyer", "director", 1]]],
  ["Kerala Backwaters", 2023, "bollywood", "Malayalam", "drama", 4, [0.8, 1, 0.5, 0.3, 0.2, 0.2, 0.5, 9, 0.1, 0.1, 0.1, 0.8, 0.1, 0.1, 4], [["Meenal Kurup", "actor", 1], ["Sunita Iyer", "director", 1]]],
  ["Hyderabad Nights", 2024, "bollywood", "Telugu", "action", 28, [10, 5, 1, 1, 0.5, 0.5, 2, 70, 0.6, 0.4, 0.8, 4, 0.1, 0.1, 16], [["Vikram Reddy", "actor", 1], ["Tara Bhatt", "actor", 3]]],
  ["Punjab di Shaan", 2022, "bollywood", "Punjabi", "comedy", 6, [5, 6, 0.3, 0.3, 0.2, 0.2, 0.2, 14, 0.2, 0.1, 0.1, 5, 0.4, 0.1, 5], [["Gurpreet Sandhu", "actor", 1], ["Tara Bhatt", "actor", 2]]],

  ["Rue des Ombres", 2022, "french", "French", "drama", 8, [4, 5, 28, 6, 5, 4, 3, 0.5, 2, 1, 1, 3, 0.1, 3, 3], [["Étienne Moreau", "actor", 1], ["Léa Fontaine", "actor", 2], ["Julien Marchetti", "director", 1]]],
  ["Le Dernier Bal", 2023, "french", "French", "comedy", 6, [2, 3, 22, 3, 3, 3, 2, 0.3, 1, 1, 0.5, 2, 0.1, 2, 2], [["Léa Fontaine", "actor", 1], ["Camille Laurent", "actor", 3], ["Julien Marchetti", "director", 1]]],

  ["Paper Lanterns", 2021, "japanese", "Japanese", "drama", 5, [2, 1, 3, 1, 1, 1, 24, 0.5, 0.5, 0.3, 0.3, 1, 0.1, 0.2, 1], [["Yui Takeda", "actor", 1], ["Hiroshi Mizuno", "director", 1]]],
  ["Samurai Dawn", 2023, "japanese", "Japanese", "action", 22, [9, 3, 3, 3, 2, 2, 38, 2, 3, 1, 2, 3, 0.2, 0.5, 4], [["Kenji Arai", "actor", 1], ["Yui Takeda", "actor", 2], ["Hiroshi Mizuno", "director", 1]]],
  ["Neon Ward", 2022, "japanese", "Japanese", "horror", 6, [4, 2, 2, 2, 1, 1, 19, 1, 1, 0.5, 0.5, 1, 0.1, 0.2, 2], [["Kenji Arai", "actor", 1], ["Hana Mori", "actor", 2]]],

  ["Karachi Nights", 2023, "pakistani", "Urdu", "drama", 3, [1.5, 3, 0.3, 0.3, 0.2, 0.2, 0.2, 0.4, 0.2, 0.1, 0.2, 1, 11, 0.1, 6], [["Zain Chaudhry", "actor", 1], ["Hira Siddiqui", "actor", 2], ["Omer Nadeem", "director", 1]]],
  ["Lahore Junction", 2022, "pakistani", "Urdu", "comedy", 2, [1, 2.5, 0.2, 0.2, 0.1, 0.1, 0.1, 0.3, 0.1, 0.1, 0.1, 0.8, 9, 0.1, 5], [["Hira Siddiqui", "actor", 1], ["Omer Nadeem", "director", 1]]],
  ["Indus Run", 2024, "pakistani", "Urdu", "action", 4, [1.2, 3, 0.3, 0.4, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.3, 0.9, 12, 0.1, 7], [["Zain Chaudhry", "actor", 1], ["Omer Nadeem", "director", 1]]],

  ["Bihar Ka Sher", 2023, "bhojpuri", "Bhojpuri", "action", 1.2, [0.3, 0.2, 0, 0, 0, 0, 0, 5, 0.1, 0, 0.1, 0.2, 0, 0, 0.6], [["Ajay Pandey", "actor", 1], ["Rani Kushwaha", "actor", 2], ["Mukesh Chaubey", "director", 1]]],
  ["Gaon Ki Gori", 2022, "bhojpuri", "Bhojpuri", "romance", 0.8, [0.2, 0.2, 0, 0, 0, 0, 0, 3.5, 0, 0, 0, 0.1, 0, 0, 0.4], [["Rani Kushwaha", "actor", 1], ["Mukesh Chaubey", "director", 1]]],
  ["Pardesi Babu", 2024, "bhojpuri", "Bhojpuri", "drama", 1, [0.3, 0.4, 0, 0, 0, 0, 0, 4.2, 0.1, 0, 0, 0.3, 0, 0, 0.9], [["Ajay Pandey", "actor", 1], ["Mukesh Chaubey", "director", 1]]],

  ["Fado Eterno", 2022, "portuguese", "Portuguese", "drama", 3, [1, 1, 2, 1, 0.8, 1.5, 0.5, 0.1, 6, 0.1, 0.1, 0.5, 0.1, 9, 0.8], [["Inês Carvalho", "actor", 1], ["Tiago Almeida", "actor", 2], ["Rui Teixeira", "director", 1]]],
  ["Atlântico", 2023, "portuguese", "Portuguese", "thriller", 4, [2, 2, 2, 1, 1, 2, 0.5, 0.1, 9, 0.1, 0.2, 0.6, 0.1, 8, 1], [["Tiago Almeida", "actor", 1], ["Beatriz Lobo", "actor", 2], ["Rui Teixeira", "director", 1]]],
  ["Lisboa Azul", 2024, "portuguese", "Portuguese", "romance", 2.5, [1, 1.5, 2, 1, 1, 1.5, 0.4, 0.1, 7, 0.1, 0.1, 0.5, 0.1, 10, 0.7], [["Beatriz Lobo", "actor", 1], ["Inês Carvalho", "actor", 2]]]
]

ALL_TERRITORIES = Territory.all.to_a
NEW_FILMS.each do |title, year, industry, language, genre, budget, grosses, crew|
  film = Film.find_or_initialize_by(title: title)
  film.update!(year: year, industry: industry, language: language, genre: genre, budget_usd: (budget * M).to_i)
  ALL_TERRITORIES.zip(grosses).each do |t, g|
    TerritoryPerformance.find_or_create_by!(film: film, territory: t) { |tp| tp.gross_usd = (g * M).to_i }
  end
  crew.each { |name, role, billing| Credit.find_or_create_by!(person: P.(name), film: film, role: role) { |c| c.billing_order = billing } }
end

# --- network: new industries hang off existing connectors ---------------------------------------
[
  ["Rita Stein", "Maya Collins", 4, "Agent"], ["Rita Stein", "Daniel Okafor", 3, nil],
  ["Meera Joshi", "Aarav Malhotra", 4, "Co-produced"], ["Meera Joshi", "Rohan Deshpande", 3, nil],
  ["Meera Joshi", "Vikram Reddy", 3, "Met at a Hyderabad market"], ["Rohan Deshpande", "Tara Bhatt", 4, nil],
  ["Vikram Reddy", "Karthik Subramanian", 2, nil], ["Priya Nair", "Meenal Kurup", 3, nil], ["Priya Nair", "Sunita Iyer", 3, nil],
  ["Aarav Malhotra", "Gurpreet Sandhu", 2, nil],
  ["Meera Joshi", "Raghav Dubey", 2, "Introduced at a Patna festival"], ["Raghav Dubey", "Ajay Pandey", 5, nil],
  ["Raghav Dubey", "Rani Kushwaha", 4, nil], ["Raghav Dubey", "Mukesh Chaubey", 4, nil],
  ["Dana Cho", "Sana Mirza", 3, "Met at Dubai film market"], ["Sana Mirza", "Zain Chaudhry", 5, nil],
  ["Sana Mirza", "Hira Siddiqui", 4, nil], ["Sana Mirza", "Omer Nadeem", 3, nil],
  ["Henrik Aalto", "Claire Dubois", 4, "Co-sell in Europe"], ["Claire Dubois", "Étienne Moreau", 4, nil],
  ["Claire Dubois", "Léa Fontaine", 4, nil], ["Claire Dubois", "Julien Marchetti", 3, nil],
  ["Dana Cho", "Kenji Arai", 3, nil], ["Dana Cho", "Yui Takeda", 3, nil], ["Dana Cho", "Hiroshi Mizuno", 4, nil],
  ["Carlos Mendes", "Tiago Almeida", 4, nil], ["Carlos Mendes", "Inês Carvalho", 4, nil],
  ["Carlos Mendes", "Beatriz Lobo", 3, nil], ["Beatriz Lobo", "Rui Teixeira", 2, nil]
].each do |a, b, s, note|
  pa, pb = P.(a), P.(b)
  next if Connection.exists?(person: pa, other_person: pb) || Connection.exists?(person: pb, other_person: pa)
  Connection.create!(person: pa, other_person: pb, strength: s, note: note)
end

puts "Industries: #{Person.group(:industry).count.sort.to_h}"
puts "Films: #{Film.group(:industry).count.sort.to_h}; territories: #{Territory.count}; connections: #{Connection.count}"
