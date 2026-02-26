class CreateConsumptionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :consumption_events do |t|
      t.references :care_subject, polymorphic: true, null: false
      t.references :consumable_item, null: false, foreign_key: true

      t.decimal :quantity, precision: 12, scale: 4, null: false
      t.string :unit, null: false, default: 'g'
      t.datetime :occurred_at, null: false
      t.string :source

      t.timestamps
    end

    add_index :consumption_events, [ :care_subject_type, :care_subject_id, :occurred_at ],
              name: 'index_consumption_events_on_care_subject_and_occurred_at'
  end
end
