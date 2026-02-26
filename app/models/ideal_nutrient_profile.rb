class IdealNutrientProfile < ApplicationRecord
  belongs_to :profilable, polymorphic: true

  validates :kcal_per_day_target, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
