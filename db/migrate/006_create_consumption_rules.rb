class CreateConsumptionRules < ActiveRecord::Migration[8.1]
  def change
    create_table :consumption_rules do |t|
      t.references :care_subject, polymorphic: true, null: false
      t.references :consumable_item, null: false, foreign_key: true

      t.decimal :amount, precision: 12, scale: 4, null: false
      t.string :unit, null: false, default: 'g'
      t.string :period, null: false
      t.boolean :active, default: true, null: false

      t.date :starts_on
      t.date :ends_on
      t.string :kind

      t.timestamps
    end

    add_index :consumption_rules, [ :care_subject_type, :care_subject_id, :consumable_item_id ],
              name: 'index_consumption_rules_on_subject_and_item'
  end
end
