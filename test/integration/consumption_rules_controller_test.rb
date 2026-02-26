require "test_helper"

class ConsumptionRulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @animal = animals(:one)
    @consumption_rule = consumption_rules(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "should get new feeding rule form when signed in" do
    sign_in @user
    get new_animal_consumption_rule_path(@animal)
    assert_response :success
  end

  test "should redirect to sign in when not authenticated for new" do
    get new_animal_consumption_rule_path(@animal)
    assert_redirected_to new_user_session_path
  end

  test "should create feeding rule for own animal" do
    sign_in @user
    assert_difference("ConsumptionRule.count", 1) do
      post animal_consumption_rules_path(@animal),
        params: { consumption_rule: { consumable_item_id: @consumable.id, amount: 80, unit: "g", period: "day", active: true } }
    end
    rule = ConsumptionRule.last
    assert_equal @animal, rule.care_subject
    assert_equal "feeding", rule.kind
    assert_redirected_to animal_path(@animal)
  end

  test "should not create feeding rule with invalid params" do
    sign_in @user
    assert_no_difference("ConsumptionRule.count") do
      post animal_consumption_rules_path(@animal),
        params: { consumption_rule: { consumable_item_id: nil, amount: 0, unit: "g", period: "day" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not access new for another user's animal" do
    sign_in users(:two)
    get new_animal_consumption_rule_path(@animal)
    assert_response :not_found
  end

  test "should get edit when signed in and own animal" do
    sign_in @user
    get edit_consumption_rule_path(@consumption_rule)
    assert_response :success
  end

  test "should update feeding rule" do
    sign_in @user
    patch consumption_rule_path(@consumption_rule),
      params: { consumption_rule: { consumable_item_id: @consumable.id, amount: 120, unit: "g", period: "day", active: true } }
    @consumption_rule.reload
    assert_equal 120, @consumption_rule.amount
    assert_redirected_to animal_path(@animal)
  end

  test "should destroy feeding rule" do
    sign_in @user
    assert_difference("ConsumptionRule.count", -1) do
      delete consumption_rule_path(@consumption_rule)
    end
    assert_redirected_to animal_path(@animal)
  end

  test "should not edit feeding rule of another user's animal" do
    sign_in users(:two)
    get edit_consumption_rule_path(@consumption_rule)
    assert_response :not_found
  end

  test "should not update feeding rule of another user's animal" do
    sign_in users(:two)
    patch consumption_rule_path(@consumption_rule),
      params: { consumption_rule: { amount: 200 } }
    assert_response :not_found
    @consumption_rule.reload
    assert_equal 100, @consumption_rule.amount
  end

  test "should not update consumption rule with another user's consumable_item_id (IDOR)" do
    sign_in @user
    foreign_consumable = consumable_items(:dog_food)
    assert_equal users(:two).id, foreign_consumable.user_id

    patch consumption_rule_path(@consumption_rule),
      params: { consumption_rule: { consumable_item_id: foreign_consumable.id, amount: 120, unit: "g", period: "day", active: true } }

    assert_response :unprocessable_entity
    @consumption_rule.reload
    assert_equal consumable_items(:cat_food).id, @consumption_rule.consumable_item_id, "consumable_item_id must not be changed to foreign user's item"
  end

  test "should not update consumption rule with non-food consumable_item (wrong category)" do
    sign_in @user
    fertilizer = consumable_items(:fertilizer)
    assert_equal "fertilizer", fertilizer.category

    patch consumption_rule_path(@consumption_rule),
      params: { consumption_rule: { consumable_item_id: fertilizer.id, amount: 120, unit: "g", period: "day", active: true } }

    assert_response :unprocessable_entity
    @consumption_rule.reload
    assert_equal consumable_items(:cat_food).id, @consumption_rule.consumable_item_id, "consumable_item_id must not accept non-food category"
  end
end
