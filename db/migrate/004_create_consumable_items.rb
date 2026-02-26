class CreateConsumableItems < ActiveRecord::Migration[8.1]
  def change
    create_table :consumable_items do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :default_unit, null: false, default: 'g'
      t.json :nutrition

      t.references :user, null: false, foreign_key: true

      t.integer :feeding_days_left, null: true
      t.boolean :feeding_needs_order, null: true

      t.timestamps
    end

    add_index :consumable_items, :category
    add_index :consumable_items, :name
  end
end
