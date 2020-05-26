class CreateStations < ActiveRecord::Migration[6.0]
  def change
    create_table :stations do |t|
      t.string :name, null: false
      t.string :abbr, null: false
    end
  end
end
