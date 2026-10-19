class AddRealDataFields < ActiveRecord::Migration[8.0]
  def change
    add_column :films, :source, :string, null: false, default: "demo"      # demo | wikidata
    add_column :films, :wikidata_id, :string
    add_column :films, :worldwide_gross_usd, :bigint                        # only when a source gives a total
    add_column :people, :source, :string, null: false, default: "demo"
    add_column :people, :wikidata_id, :string
    add_index :films, :wikidata_id, unique: true, where: "wikidata_id IS NOT NULL"
    add_index :people, :wikidata_id, unique: true, where: "wikidata_id IS NOT NULL"
  end
end
