class CreateTripGames < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_games do |t|
      t.references :trip, null: false, foreign_key: true, index: false
      t.references :stadium, null: false, foreign_key: true
      t.bigint :game_pk, null: false
      t.date :game_date, null: false
      t.string :home_team_name
      t.string :away_team_name
      t.string :venue_name
      t.boolean :attended, default: false, null: false

      t.timestamps
    end

    add_index :trip_games, [ :trip_id, :game_pk ], unique: true
  end
end
