namespace :wikidata do
  desc "Import real films, directors and cast from Wikidata. Optional: INDUSTRIES=french,japanese"
  task import: :environment do
    industries = ENV["INDUSTRIES"]&.split(",") || WikidataImporter::INDUSTRIES.keys
    $stdout.sync = true
    summary = WikidataImporter.new(industries: industries, logger: Logger.new($stdout)).call
    summary.each { |industry, result| puts "#{industry.ljust(11)} #{result}" }
    puts "Films from Wikidata: #{Film.where(source: 'wikidata').count}, people: #{Person.where(source: 'wikidata').count}"
  end
end
