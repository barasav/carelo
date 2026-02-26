class CreateStockLots < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_lots do |t|
      t.references :consumable_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.decimal :quantity, precision: 12, scale: 4, null: false
      t.string :unit, null: false, default: 'g'
      t.date :purchased_on, null: false
      t.date :expires_on
      t.string :notes

      t.timestamps
    end

    add_index :stock_lots, [ :consumable_item_id, :purchased_on ]
  end
end
