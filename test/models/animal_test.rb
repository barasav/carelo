require "test_helper"

class AnimalTest < ActiveSupport::TestCase
  setup do
    @animal = animals(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "feeding_has_rules? returns true when animal has feeding rules" do
    assert @animal.feeding_consumable_items.exists?
    assert @animal.feeding_has_rules?
  end

  test "feeding_has_rules? returns false when no feeding rules" do
    @animal.consumption_rules.destroy_all
    assert_not @animal.feeding_has_rules?
  end
end
