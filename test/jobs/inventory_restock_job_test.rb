require "test_helper"

class InventoryRestockJobTest < ActiveJob::TestCase
  test "creates RestockAlert when days_left below threshold" do
    animal = animals(:one)
    consumable = consumable_items(:cat_food)
    assert_difference("RestockAlert.count", 1) do
      InventoryRestockJob.perform_now(threshold_days: 60)
    end

    alert = RestockAlert.find_by(care_subject: animal, consumable_item: consumable)
    assert alert.present?
    assert alert.days_left < 60
    assert_equal false, alert.acknowledged
  end

  test "does not create alert when days_left above threshold" do
    assert_no_difference("RestockAlert.count") do
      InventoryRestockJob.perform_now(threshold_days: InventoryTrackable::DEFAULT_RESTOCK_THRESHOLD_DAYS)
    end
  end

  test "updates feeding item cache when stock available" do
    animal = animals(:one)
    feeding_item = consumable_items(:cat_food)
    InventoryRestockJob.perform_now

    feeding_item.reload
    assert_equal false, feeding_item.feeding_needs_order
    assert_equal 33, feeding_item.feeding_days_left
  end

  test "updates feeding item cache when stock depleted" do
    animal = animals(:one)
    animal.user.stock_lots.where(consumable_item: consumable_items(:cat_food)).destroy_all

    InventoryRestockJob.perform_now

    consumable_items(:cat_food).reload
    assert_equal true, consumable_items(:cat_food).feeding_needs_order
    assert_nil consumable_items(:cat_food).feeding_days_left
  end

  test "no feeding items when animal has no feeding rules" do
    animal = animals(:three)
    assert_empty animal.feeding_consumable_items
  end

  test "feeding_days_left is minimum when item shared by multiple animals" do
    InventoryRestockJob.perform_now

    consumable_items(:cat_food).reload
    assert_equal 33, consumable_items(:cat_food).feeding_days_left,
                 "feeding_days_left must be minimum across animals, not last overwrite"
  end
end
