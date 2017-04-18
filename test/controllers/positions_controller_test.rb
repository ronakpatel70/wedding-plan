require 'test_helper'

class PositionsControllerTest < BaseTest
  setup do
    @position = positions(:door_host)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:positions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create position" do
    assert_difference('Position.count') do
      post :create, params: { position: { name: 'Test', short_description: 'test position', quantity: 1 } }
    end

    assert_redirected_to :positions
  end

  test "should show position" do
    get :show, params: { id: @position }
    assert_response :success
  end

  test "should update position" do
    patch :update, params: { id: @position, position: { quantity: 2 } }
    assert_redirected_to :positions
  end

  test "should show error message" do
    patch :update, params: { id: @position, position: { name: '' } }
    assert_response :success
    assert assigns(:position)
  end

  test "should destroy position" do
    assert_difference('Position.count', -1) do
      delete :destroy, params: { id: @position }
    end

    assert_redirected_to :positions
  end
end
