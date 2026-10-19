# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_19_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "connections", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "other_person_id", null: false
    t.integer "strength", default: 3, null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["other_person_id"], name: "index_connections_on_other_person_id"
    t.index ["person_id", "other_person_id"], name: "index_connections_on_person_id_and_other_person_id", unique: true
    t.index ["person_id"], name: "index_connections_on_person_id"
  end

  create_table "credits", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "film_id", null: false
    t.string "role", default: "actor", null: false
    t.integer "billing_order", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["film_id"], name: "index_credits_on_film_id"
    t.index ["person_id", "film_id", "role"], name: "index_credits_on_person_id_and_film_id_and_role", unique: true
    t.index ["person_id"], name: "index_credits_on_person_id"
  end

  create_table "data_sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.text "description"
    t.text "data_to_scrape"
    t.string "access_method", null: false
    t.string "tos_status", null: false
    t.text "notes"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_data_sources_on_name", unique: true
  end

  create_table "films", force: :cascade do |t|
    t.string "title", null: false
    t.integer "year"
    t.string "genre"
    t.bigint "budget_usd"
    t.string "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "industry", default: "hollywood", null: false
    t.string "language"
    t.string "source", default: "demo", null: false
    t.string "wikidata_id"
    t.bigint "worldwide_gross_usd"
    t.index ["industry"], name: "index_films_on_industry"
    t.index ["wikidata_id"], name: "index_films_on_wikidata_id", unique: true, where: "(wikidata_id IS NOT NULL)"
  end

  create_table "package_members", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "person_id", null: false
    t.string "role", null: false
    t.bigint "fee_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_package_members_on_person_id"
    t.index ["project_id", "person_id"], name: "index_package_members_on_project_id_and_person_id", unique: true
    t.index ["project_id"], name: "index_package_members_on_project_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.string "kind", default: "actor", null: false
    t.text "bio"
    t.string "nationality"
    t.bigint "fee_usd"
    t.string "politics_lean"
    t.bigint "social_followers"
    t.decimal "social_engagement_pct", precision: 5, scale: 2
    t.integer "controversy_level", default: 0, null: false
    t.text "persona_notes"
    t.boolean "is_self", default: false, null: false
    t.string "tmdb_id"
    t.string "imdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "industry", default: "hollywood", null: false
    t.string "source", default: "demo", null: false
    t.string "wikidata_id"
    t.index ["industry"], name: "index_people_on_industry"
    t.index ["is_self"], name: "index_people_on_is_self", unique: true, where: "is_self"
    t.index ["name"], name: "index_people_on_name"
    t.index ["wikidata_id"], name: "index_people_on_wikidata_id", unique: true, where: "(wikidata_id IS NOT NULL)"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.string "genre"
    t.text "logline"
    t.bigint "budget_usd"
    t.string "political_leaning", default: "none", null: false
    t.string "status", default: "development", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "territories", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "kind", default: "country", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_territories_on_code", unique: true
  end

  create_table "territory_performances", force: :cascade do |t|
    t.bigint "film_id", null: false
    t.bigint "territory_id", null: false
    t.bigint "gross_usd", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["film_id", "territory_id"], name: "index_territory_performances_on_film_id_and_territory_id", unique: true
    t.index ["film_id"], name: "index_territory_performances_on_film_id"
    t.index ["territory_id"], name: "index_territory_performances_on_territory_id"
  end

  add_foreign_key "connections", "people"
  add_foreign_key "connections", "people", column: "other_person_id"
  add_foreign_key "credits", "films"
  add_foreign_key "credits", "people"
  add_foreign_key "package_members", "people"
  add_foreign_key "package_members", "projects"
  add_foreign_key "territory_performances", "films"
  add_foreign_key "territory_performances", "territories"
end
