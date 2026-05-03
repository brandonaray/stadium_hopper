class CreateStadiums < ActiveRecord::Migration[8.1]
  def change
    create_table :stadiums do |t|
      t.string :name, null: false
      t.string :team_name, null: false
      t.string :city, null: false
      t.string :state
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.integer :mlb_venue_id, null: false
      t.integer :capacity
      t.integer :opened_year
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :stadiums, :mlb_venue_id, unique: true
  end
end
