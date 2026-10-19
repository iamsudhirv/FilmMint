class CreateCoreSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :data_sources do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.text :description
      t.text :data_to_scrape
      t.string :access_method, null: false
      t.string :tos_status, null: false
      t.text :notes
      t.string :url
      t.timestamps
    end
    add_index :data_sources, :name, unique: true

    create_table :people do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: "actor" # actor, director, producer, cinematographer, writer, agent, sales_agent
      t.text :bio
      t.string :nationality
      t.bigint :fee_usd                              # asking fee
      t.string :politics_lean                        # left, center, right (producer-entered)
      t.bigint :social_followers
      t.decimal :social_engagement_pct, precision: 5, scale: 2
      t.integer :controversy_level, null: false, default: 0 # 0 none .. 3 severe
      t.text :persona_notes
      t.boolean :is_self, null: false, default: false
      t.string :tmdb_id
      t.string :imdb_id
      t.timestamps
    end
    add_index :people, :name
    add_index :people, :is_self, unique: true, where: "is_self"

    create_table :films do |t|
      t.string :title, null: false
      t.integer :year
      t.string :genre
      t.bigint :budget_usd
      t.string :tmdb_id
      t.timestamps
    end

    create_table :credits do |t|
      t.references :person, null: false, foreign_key: true
      t.references :film, null: false, foreign_key: true
      t.string :role, null: false, default: "actor"
      t.integer :billing_order, null: false, default: 1
      t.timestamps
    end
    add_index :credits, %i[person_id film_id role], unique: true

    create_table :territories do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :kind, null: false, default: "country" # country or group (e.g. LatAm, Balkans)
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :territories, :code, unique: true

    create_table :territory_performances do |t|
      t.references :film, null: false, foreign_key: true
      t.references :territory, null: false, foreign_key: true
      t.bigint :gross_usd, null: false, default: 0
      t.timestamps
    end
    add_index :territory_performances, %i[film_id territory_id], unique: true

    create_table :projects do |t|
      t.string :title, null: false
      t.string :genre
      t.text :logline
      t.bigint :budget_usd
      t.string :political_leaning, null: false, default: "none" # none, left, center, right
      t.string :status, null: false, default: "development"
      t.timestamps
    end

    create_table :package_members do |t|
      t.references :project, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :role, null: false
      t.bigint :fee_usd # overrides the person's asking fee
      t.timestamps
    end
    add_index :package_members, %i[project_id person_id], unique: true

    create_table :connections do |t|
      t.references :person, null: false, foreign_key: true
      t.references :other_person, null: false, foreign_key: { to_table: :people }
      t.integer :strength, null: false, default: 3 # 1 acquaintance .. 5 close
      t.string :note
      t.timestamps
    end
    add_index :connections, %i[person_id other_person_id], unique: true
  end
end
