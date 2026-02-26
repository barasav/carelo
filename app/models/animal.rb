class Animal < ApplicationRecord
  include InventoryTrackable

  SPECIES = %w[cat horse dog bird].freeze

  belongs_to :user
  has_many :restock_alerts, as: :care_subject, dependent: :destroy
  has_one :ideal_nutrient_profile, as: :profilable, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }

  def self.refresh_feeding_status_for_consumable_item(consumable_item)
    animals = joins(:consumption_rules)
      .where(consumption_rules: { kind: "feeding", consumable_item_id: consumable_item.id })
      .distinct
      .to_a

    return if animals.empty?

    days_values = animals.filter_map { |animal| animal.days_left(consumable_item) }
    days = days_values.min
    needs_order = days.nil? || days <= 0

    consumable_item.update_columns(
      feeding_needs_order: needs_order,
      feeding_days_left: days&.floor
    )
  end

  def self.permitted_attributes
    %i[name species]
  end

  def feeding_consumable_items
    ConsumableItem.where(id: consumption_rules.where(kind: :feeding).select(:consumable_item_id).distinct)
  end

  def feeding_has_rules?
    feeding_consumable_items.exists?
  end

  def feeding_item_names
    feeding_consumable_items.where(feeding_needs_order: true).pluck(:name).join(", ").presence
  end

  def feeding_days_left
    feeding_consumable_items.where.not(feeding_days_left: nil).minimum(:feeding_days_left) || 0
  end

  def feeding_needs_order
    feeding_consumable_items.where(feeding_needs_order: true).exists?
  end
end
