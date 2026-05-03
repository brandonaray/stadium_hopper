class CreateVisitedStadiums < ActiveRecord::Migration[8.1]
  def change
    create_table :visited_stadiums do |t|
      t.references :stadium, null: false, foreign_key: true, index: { unique: true }
      t.date :visited_on
      t.text :notes

      t.timestamps
    end
  end
end
