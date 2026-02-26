class CreatePlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      t.date :blooming_start_date
      t.date :blooming_end_date
      t.string :location
      t.string :light
      t.string :watering_amount
      t.string :fertilizer_type
      t.string :fertilizer_amount
      t.integer :watering_interval_days
      t.integer :fertilizing_interval_days

      t.boolean :watered_ok
      t.boolean :fertilized_ok
      t.datetime :last_checked_at

      t.timestamps null: false
    end

    add_index :plants, [ :user_id, :name ]
  end
end
