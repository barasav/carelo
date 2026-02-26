require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @plant = plants(:one)
    @animal = animals(:one)
  end

  test "should get index when signed in" do
    sign_in @user
    get root_path
    assert_response :success
  end

  test "should redirect to sign in when not authenticated" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "index shows plants and animals sections when signed in" do
    sign_in @user
    get root_path
    assert_response :success
  end

  test "index shows user plants and animals" do
    sign_in @user
    get root_path
    assert_response :success
  end
end
