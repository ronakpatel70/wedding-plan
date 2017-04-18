require 'test_helper'

class PrizesControllerTest < BaseTest
  setup do
    @prize = prizes(:one)
  end

  test "should get index" do
    get :index, params: { show_id: shows(:one) }
    assert_response :success
    assert_not_nil assigns(:prizes)
  end

  test "should get new" do
    get :new, params: { show_id: shows(:one) }
    assert_response :success
  end

  test "should create prize" do
    assert_difference('Prize.count') do
      post :create, params: { prize: { vendor_id: vendors(:one), name: 'Test Prize 2', quantity: 1, value: 2000, rules: 'A bunch of rules.', type: 'discount' }, show_id: shows(:one) }
    end

    assert_redirected_to :prizes
  end

  test "should show prize" do
    get :show, params: { id: @prize }
    assert_response :success
  end

#   test "should get edit" do
#     get :edit, id: @prize
#     assert_response :success
#   end

  test "should update prize" do
    patch :update, params: { id: @prize, prize: { value: 2000, manned: true } }
    assert_redirected_to :prizes
  end

  test "should destroy prize" do
    assert_difference('Prize.count', -1) do
      delete :destroy, params: { id: @prize }
    end

    assert_redirected_to :prizes
  end
end
