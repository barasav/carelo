module ConsumptionRulesHelper
  def consumable_items_for_feed_select(animal)
    animal.user.consumable_items.for_food.order(:name)
  end
end
