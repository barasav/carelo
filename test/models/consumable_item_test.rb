require "test_helper"

class ConsumableItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "days_left returns nil when no consumption rules" do
    @consumable.consumption_rules.destroy_all
    assert_nil @consumable.days_left
  end

  test "days_left returns value when single care subject has rules" do
    left = @consumable.days_left
    assert left.present?
    assert_in_delta 33.33, left, 0.01
  end

  test "days_left returns minimum across multiple care subjects with rules" do
    animal_two = animals(:two)
    animal_two.consumption_rules.where(consumable_item: @consumable).destroy_all
    animal_two.consumption_rules.create!(
      consumable_item: @consumable,
      amount: 500,
      unit: "g",
      period: "day",
      active: true,
      kind: "feeding"
    )

    left = @consumable.days_left
    assert left.present?
    assert_in_delta 10, left, 0.01, "Should return minimum (10) when one rule gives ~32 days and another 10 days"
  end
end
