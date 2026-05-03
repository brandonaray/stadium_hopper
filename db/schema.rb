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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_003323) do
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
end
