class ConsumptionEvent < ApplicationRecord
  belongs_to :care_subject, polymorphic: true
  belongs_to :consumable_item

  after_commit :refresh_animal_feeding_status, on: %i[create update destroy]
  after_commit :refresh_plant_care_status, on: %i[create update destroy]

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true, inclusion: { in: UnitConverter::SUPPORTED_UNITS }
  validates :occurred_at, presence: true

  scope :recent_first, -> { order(occurred_at: :desc) }

  private

  def refresh_animal_feeding_status
    consumable_item.refresh_inventory_dependent_status
  end

  def refresh_plant_care_status
    return unless care_subject.is_a?(Plant)
    return if care_subject.destroyed?
    return unless %w[water fertilizer].include?(consumable_item.category)

    care_subject.update_care_status!
  end
end
