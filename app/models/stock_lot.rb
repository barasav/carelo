class StockLot < ApplicationRecord
  belongs_to :consumable_item
  belongs_to :user

  after_initialize :set_defaults, if: :new_record?
  after_commit :refresh_animal_feeding_status, on: %i[create update destroy]

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true, inclusion: { in: UnitConverter::SUPPORTED_UNITS }
  validates :purchased_on, presence: true
  validate  :expires_on_after_purchased_on

  def self.permitted_attributes
    %i[consumable_item_id quantity unit purchased_on expires_on notes]
  end

  private

  def set_defaults
    self.quantity ||= 0
    self.unit ||= consumable_item.default_unit if consumable_item.present?
    self.purchased_on ||= Date.current
  end

  def refresh_animal_feeding_status
    consumable_item.refresh_inventory_dependent_status
  end

  def expires_on_after_purchased_on
    return if expires_on.blank? || purchased_on.blank?

    errors.add(:expires_on, :must_be_after_purchased_on) if expires_on < purchased_on
  end
end
