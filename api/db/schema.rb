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

ActiveRecord::Schema[7.0].define(version: 2023_03_08_034314) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.float "default_mean", null: false
    t.float "default_deviation", null: false
    t.string "emoji_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "requires_score", default: false, null: false
    t.text "slack_channel_id"
    t.text "slack_emoji_url"
    t.text "slack_unaliased_name"
    t.index ["emoji_name"], name: "index_games_on_emoji_name", unique: true
    t.index ["name"], name: "index_games_on_name", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_matches_on_game_id"
  end

  create_table "players", force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  create_table "players_teams", id: false, force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "team_id", null: false
    t.index ["player_id"], name: "index_players_teams_on_player_id"
    t.index ["team_id"], name: "index_players_teams_on_team_id"
  end

  create_table "rating_events", force: :cascade do |t|
    t.bigint "rating_id", null: false
    t.bigint "match_id", null: false
    t.float "mean", null: false
    t.float "deviation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_rating_events_on_match_id"
    t.index ["rating_id"], name: "index_rating_events_on_rating_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.float "mean", null: false
    t.float "deviation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["player_id"], name: "index_ratings_on_player_id"
  end

  create_table "results", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "team_id", null: false
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "place"
    t.index ["match_id"], name: "index_results_on_match_id"
    t.index ["team_id"], name: "index_results_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "matches", "games"
  add_foreign_key "players_teams", "players"
  add_foreign_key "players_teams", "teams"
  add_foreign_key "rating_events", "matches"
  add_foreign_key "rating_events", "ratings"
  add_foreign_key "ratings", "games"
  add_foreign_key "ratings", "players"
  add_foreign_key "results", "matches"
  add_foreign_key "results", "teams"
end
