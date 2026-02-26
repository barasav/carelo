class CreateAnimals < ActiveRecord::Migration[8.1]
  def change
    create_table :animals do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      t.string :species, null: false

      t.timestamps
    end

    add_index :animals, [ :user_id, :name ]
  end
end
