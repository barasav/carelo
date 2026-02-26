require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @plant = plants(:one)
  end

  test "should get index when signed in" do
    sign_in @user
    get plants_path
    assert_response :success
  end

  test "should redirect to sign in when not authenticated" do
    get plants_path
    assert_redirected_to new_user_session_path
  end

  test "should get show when signed in" do
    sign_in @user
    get plant_path(@plant)
    assert_response :success
  end

  test "should not show plant of another user" do
    sign_in users(:two)
    get plant_path(@plant)
    assert_response :not_found
  end

  test "should get new when signed in" do
    sign_in @user
    get new_plant_path
    assert_response :success
  end

  test "should create plant when signed in with valid params" do
    sign_in @user
    assert_difference("Plant.count", 1) do
      post plants_path, params: { plant: { name: "Nová rostlina" } }
    end
    assert_redirected_to plant_path(Plant.last)
    assert_equal @user.id, Plant.last.user_id
  end

  test "should not assign user_id from params when creating plant" do
    sign_in @user
    other_user = users(:two)
    post plants_path, params: { plant: { name: "Hijacked", user_id: other_user.id } }
    assert_redirected_to plant_path(Plant.last)
    assert_equal @user.id, Plant.last.user_id
    assert_not_equal other_user.id, Plant.last.user_id
  end

  test "should not create plant with invalid params" do
    sign_in @user
    assert_no_difference("Plant.count") do
      post plants_path, params: { plant: { name: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit when signed in" do
    sign_in @user
    get edit_plant_path(@plant)
    assert_response :success
  end

  test "should update plant when signed in with valid params" do
    sign_in @user
    patch plant_path(@plant), params: { plant: { name: "Updated name" } }
    assert_redirected_to plant_path(@plant)
    @plant.reload
    assert_equal "Updated name", @plant.name
  end

  test "should not update plant with invalid params" do
    sign_in @user
    patch plant_path(@plant), params: { plant: { watering_interval_days: -1 } }
    assert_response :unprocessable_entity
    @plant.reload
    assert_not_equal(-1, @plant.watering_interval_days)
  end

  test "should destroy plant when signed in" do
    sign_in @user
    assert_difference("Plant.count", -1) do
      delete plant_path(@plant)
    end
    assert_redirected_to plants_path
  end

  test "should not destroy plant of another user" do
    sign_in users(:two)
    assert_no_difference("Plant.count") do
      delete plant_path(@plant)
    end
    assert_response :not_found
  end
end
