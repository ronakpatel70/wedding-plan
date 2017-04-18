require 'test_helper'

class FeesControllerTest < BaseTest
  setup do
    @booth = booths(:one)
    @fee = fees(:one)
  end

  test "should get new" do
    get :new, params: { booth_id: @booth }
    assert_response :success
  end

  test "should create fee" do
    assert_difference('Fee.count') do
      post :create, params: { fee: { description: "Test fee", amount: "$123.99" }, booth_id: @booth }
    end

    assert_redirected_to booth_path(@fee.booth)
    assert_equal 12399, Fee.last.amount
  end

  test "should destroy fee" do
    assert_difference('Fee.count', -1) do
      delete :destroy, params: { id: @fee }
    end

    assert_redirected_to booth_path(@fee.booth)
  end
end
