class CreateIdealNutrientProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :ideal_nutrient_profiles do |t|
      t.references :profilable, polymorphic: true, null: false

      t.decimal :kcal_per_day_target, precision: 10, scale: 2
      t.json :nutrients_target

      t.timestamps
    end
  end
end
