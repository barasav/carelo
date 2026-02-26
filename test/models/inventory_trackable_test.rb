require "test_helper"

class InventoryTrackableTest < ActiveSupport::TestCase
  setup do
    @animal = animals(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "on_stock returns stock minus consumption for animal" do
    on_stock = @animal.on_stock(@consumable)
    assert_equal 5000, on_stock
  end

  test "daily_burn returns sum of all active consumption rules for item" do
    burn = @animal.daily_burn(@consumable)
    assert_equal 150, burn
  end

  test "days_left returns on_stock divided by daily_burn" do
    left = @animal.days_left(@consumable)
    assert_in_delta 33.33, left, 0.01
  end

  test "days_left returns nil when daily_burn is zero" do
    consumable = consumable_items(:water)
    left = @animal.days_left(consumable)
    assert_nil left
  end

  test "restock_date returns date when days_left below threshold" do
    date = @animal.restock_date(@consumable, threshold_days: 7)
    assert date.is_a?(Date)
    assert_in_delta 26, (date - Time.current.to_date).to_i, 2

    date = @animal.restock_date(@consumable, threshold_days: 60)
    assert date.is_a?(Date)
    assert date >= Time.current.to_date
  end

  test "last_consumption_at returns most recent event for category" do
    plant = plants(:one)
    last = plant.last_consumption_at(category: "water")
    assert last.present?
    assert last >= 3.days.ago
    assert last <= 1.day.ago
  end
end
