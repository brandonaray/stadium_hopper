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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_055752) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "stadiums", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "capacity"
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.integer "mlb_venue_id", null: false
    t.string "name", null: false
    t.integer "opened_year"
    t.string "state"
    t.string "team_name", null: false
    t.datetime "updated_at", null: false
    t.index ["mlb_venue_id"], name: "index_stadiums_on_mlb_venue_id", unique: true
  end

  create_table "trip_games", force: :cascade do |t|
    t.boolean "attended", default: false, null: false
    t.string "away_team_name"
    t.datetime "created_at", null: false
    t.date "game_date", null: false
    t.bigint "game_pk", null: false
    t.string "home_team_name"
    t.bigint "stadium_id", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.string "venue_name"
    t.index ["stadium_id"], name: "index_trip_games_on_stadium_id"
    t.index ["trip_id", "game_pk"], name: "index_trip_games_on_trip_id_and_game_pk", unique: true
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "name", null: false
    t.text "notes"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.check_constraint "end_date IS NULL OR start_date IS NULL OR end_date >= start_date", name: "trips_end_date_after_start_date"
  end

  create_table "visited_stadiums", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "stadium_id", null: false
    t.datetime "updated_at", null: false
    t.date "visited_on"
    t.index ["stadium_id"], name: "index_visited_stadiums_on_stadium_id", unique: true
  end

  add_foreign_key "trip_games", "stadiums"
  add_foreign_key "trip_games", "trips"
  add_foreign_key "visited_stadiums", "stadiums"
end
