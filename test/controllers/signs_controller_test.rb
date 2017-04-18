require 'test_helper'

class SignsControllerTest < BaseTest
  setup do
    @sign = signs(:one)
    @show = shows(:two)
  end

  test "should get index" do
    get :index, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:signs)
  end

  test "should get new" do
    get :new, params: { show_id: @show }
    assert_response :success
  end

  test "should create sign" do
    assert_difference('Sign.count') do
      post :create, params: { sign: {
        front: 'Front', back: 'Back', missing: false, informational: false,
        vendor_ids: [vendors(:one), 'invalid'] }, show_id: @show }
    end

    assert_redirected_to :signs
    assert_equal 1, assigns(:sign).vendors.count
  end

  test "should show sign" do
    get :show, params: { id: @sign }
    assert_response :success
  end

  test "should update sign" do
    patch :update, params: { id: @sign, sign: { back: 'Back of sign', vendor_ids: [vendors(:one).id, vendors(:two).id] } }
    assert_redirected_to :signs
    assert_equal 2, assigns(:sign).vendors.count
  end

  test "should update sign with invalid vendors" do
    patch :update, params: { id: @sign, sign: { vendor_ids: ['wrong', 'also wrong'] } }
    assert_redirected_to :signs
  end

  test "should destroy sign" do
    assert_difference('Sign.count', -1) do
      delete :destroy, params: { id: @sign }
    end

    assert_redirected_to :signs
  end
end
