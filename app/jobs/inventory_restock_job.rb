class InventoryRestockJob < ApplicationJob
  queue_as :default

  def perform(threshold_days: InventoryTrackable::DEFAULT_RESTOCK_THRESHOLD_DAYS)
    ConsumableItem
      .joins(:consumption_rules)
      .merge(ConsumptionRule.active_now)
      .distinct
      .find_each do |item|
        item.refresh_inventory_dependent_status(threshold_days: threshold_days)
      end
  end
end
