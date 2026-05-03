class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string :name, null: false
      t.date :start_date
      t.date :end_date
      t.text :notes

      t.timestamps

      t.check_constraint "end_date IS NULL OR start_date IS NULL OR end_date >= start_date", name: "trips_end_date_after_start_date"
    end
  end
end
