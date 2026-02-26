require "test_helper"

class AnimalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @animal = animals(:one)
  end

  test "should get index when signed in" do
    sign_in @user
    get animals_path
    assert_response :success
  end

  test "should redirect to sign in when not authenticated" do
    get animals_path
    assert_redirected_to new_user_session_path
  end

  test "should not show animal of another user" do
    sign_in users(:two)
    get animal_path(@animal)
    assert_response :not_found
  end

  test "should create animal for current user" do
    sign_in @user
    assert_difference("Animal.count", 1) do
      post animals_path, params: { animal: { name: "Nová kočka", species: "cat" } }
    end
    assert_equal @user.id, Animal.last.user_id
  end

  test "show displays feeding rules section" do
    sign_in @user
    get animal_path(@animal)
    assert_response :success
  end
end
