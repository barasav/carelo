require "test_helper"

class ConsumptionRuleTest < ActiveSupport::TestCase
  test "fixture one is valid" do
    assert consumption_rules(:one).valid?
  end

  test "daily_amount_in_default_unit for period day returns amount" do
    rule = consumption_rules(:one)
    rule.update!(period: "day", amount: 100, unit: "g")
    consumable = consumable_items(:cat_food)
    assert_equal 100, rule.daily_amount_in_default_unit(consumable)
  end

  test "daily_amount_in_default_unit for period week divides by 7" do
    rule = consumption_rules(:one)
    rule.update!(period: "week", amount: 700, unit: "g")
    consumable = consumable_items(:cat_food)
    assert_in_delta 100, rule.daily_amount_in_default_unit(consumable), 0.01
  end
end
