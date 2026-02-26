class CreateRestockAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :restock_alerts do |t|
      t.references :care_subject, polymorphic: true, null: false
      t.references :consumable_item, null: false, foreign_key: true

      t.decimal :days_left, precision: 8, scale: 2
      t.date :restock_by
      t.boolean :acknowledged, default: false, null: false

      t.timestamps
    end

    add_index :restock_alerts, :acknowledged
  end
end
