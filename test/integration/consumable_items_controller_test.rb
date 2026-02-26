require "test_helper"

class ConsumableItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "should get index when signed in" do
    sign_in @user
    get consumable_items_path
    assert_response :success
  end

  test "should redirect to sign in when not authenticated" do
    get consumable_items_path
    assert_redirected_to new_user_session_path
  end

  test "should get show when signed in" do
    sign_in @user
    get consumable_item_path(@consumable)
    assert_response :success
  end

  test "should get new when signed in" do
    sign_in @user
    get new_consumable_item_path
    assert_response :success
  end

  test "should create consumable item when signed in with valid params" do
    sign_in @user
    assert_difference("ConsumableItem.count", 1) do
      post consumable_items_path,
        params: {
          consumable_item: {
            name: "New food",
            category: "food",
            default_unit: "g"
          }
        }
    end
    item = ConsumableItem.last
    assert_equal "New food", item.name
    assert_equal @user.id, item.user_id
    assert_redirected_to consumable_item_path(item)
  end

  test "should not create consumable item with invalid params" do
    sign_in @user
    assert_no_difference("ConsumableItem.count") do
      post consumable_items_path,
        params: { consumable_item: { name: nil, category: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit when signed in" do
    sign_in @user
    get edit_consumable_item_path(@consumable)
    assert_response :success
  end

  test "should update consumable item when signed in" do
    sign_in @user
    patch consumable_item_path(@consumable),
      params: { consumable_item: { name: "Updated name", category: "food", default_unit: "g" } }
    @consumable.reload
    assert_equal "Updated name", @consumable.name
    assert_redirected_to consumable_item_path(@consumable)
  end

  test "should destroy consumable item when signed in" do
    sign_in @user
    assert_difference("ConsumableItem.count", -1) do
      delete consumable_item_path(consumable_items(:fertilizer))
    end
    assert_redirected_to consumable_items_path
  end
end
