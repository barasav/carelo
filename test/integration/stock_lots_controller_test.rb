require "test_helper"

class StockLotsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @stock_lot = stock_lots(:one)
    @consumable = consumable_items(:cat_food)
  end

  test "should get index when signed in" do
    sign_in @user
    get stock_lots_path
    assert_response :success
  end

  test "should redirect to sign in when not authenticated" do
    get stock_lots_path
    assert_redirected_to new_user_session_path
  end

  test "should get new when signed in via consumable item" do
    sign_in @user
    get new_consumable_item_stock_lot_path(@consumable)
    assert_response :success
  end

  test "should create stock lot when signed in with valid params via consumable item" do
    sign_in @user
    assert_difference("StockLot.count", 1) do
      post consumable_item_stock_lots_path(@consumable),
        params: {
          stock_lot: {
            quantity: 1000,
            unit: "g",
            purchased_on: Date.current
          }
        }
    end
    lot = StockLot.last
    assert_equal @user.id, lot.user_id
    assert_equal @consumable.id, lot.consumable_item_id
    assert_redirected_to stock_lots_path
  end

  test "should not create stock lot with invalid params" do
    sign_in @user
    assert_no_difference("StockLot.count") do
      post consumable_item_stock_lots_path(@consumable),
        params: { stock_lot: { quantity: -1, unit: "invalid", purchased_on: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit when signed in and own stock lot" do
    sign_in @user
    get edit_stock_lot_path(@stock_lot)
    assert_response :success
  end

  test "should update stock lot quantity when signed in" do
    sign_in @user
    patch stock_lot_path(@stock_lot),
      params: { stock_lot: { quantity: 3000, unit: "g", purchased_on: @stock_lot.purchased_on } }
    @stock_lot.reload
    assert_equal 3000, @stock_lot.quantity
    assert_redirected_to stock_lots_path
  end

  test "should destroy stock lot when signed in" do
    sign_in @user
    assert_difference("StockLot.count", -1) do
      delete stock_lot_path(@stock_lot)
    end
    assert_redirected_to stock_lots_path
  end

  test "should not edit stock lot of another user" do
    sign_in users(:two)
    get edit_stock_lot_path(@stock_lot)
    assert_response :not_found
  end

  test "should not update stock lot of another user" do
    sign_in users(:two)
    patch stock_lot_path(@stock_lot),
      params: { stock_lot: { quantity: 9999 } }
    assert_response :not_found
    @stock_lot.reload
    assert_equal 5000, @stock_lot.quantity
  end
end
