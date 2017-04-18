require 'test_helper'

class PointsControllerTest < BaseTest
  setup do
    @point = points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create point" do
    assert_difference('Point.count') do
      post :create, params: { point: { vendor_id: vendors(:one), event_id: events(:four), status: 'confirmed', quantity: 3 } }
    end

    assert_redirected_to :points
  end

  test "should show point" do
    get :show, params: { id: @point }
    assert_response :success
  end

  test "should update point" do
    patch :update, params: { id: @point, point: { status: 'confirmed', quantity: 3 } }
    assert_redirected_to :points
  end

  test "should destroy point" do
    assert_difference('Point.count', -1) do
      delete :destroy, params: { id: @point }
    end

    assert_redirected_to :points
  end
end
