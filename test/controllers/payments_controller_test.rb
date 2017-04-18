require 'test_helper'

class PaymentsControllerTest < BaseTest
  setup do
    @payment = payments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payments)
  end

  test "should get new" do
    get :new, params: { booth_id: booths(:one) }
    assert_response :success
  end

  test "should create booth payment" do
    request.env["HTTP_REFERER"] = booth_path(booths(:one))
    assert_difference('Payment.count') do
      post :create, params: { payment: {
        amount: 100, description: 'Test payment', method: :cash }, booth_id: booths(:one) }
    end

    assert_redirected_to booth_path(assigns(:payment).payable)
  end

  test "should create vendor payment" do
    request.env["HTTP_REFERER"] = vendor_path(vendors(:one))
    assert_difference('Payment.count') do
      post :create, params: { payment: { amount: 100, description: 'Test payment', method: :cash }, vendor_id: vendors(:one) }
    end

    assert_redirected_to vendor_path(assigns(:payment).payer)
  end

  test "should show payment" do
    get :show, params: { id: @payment }
    assert_response :success
  end

  test "should update payment" do
    request.env["HTTP_REFERER"] = payments_path
    patch :update, params: { id: @payment, payment: { description: 'Another description' } }
    assert_redirected_to payments_path
  end

  test "should destroy payment" do
    request.env["HTTP_REFERER"] = payments_path
    assert_difference('Payment.count', -1) do
      delete :destroy, params: { id: @payment }
    end

    assert_redirected_to payments_path
  end

  test "should pay scheduled payment" do
    stub_request(:post, PY_URL).to_return(:body => File.open("test/stubs/charge.json"))

    post :pay, params: { id: payments(:scheduled).id }

    assert_requested :post, PY_URL
    assert_redirected_to payments_path
    assert_equal 'Payment was successfully paid.', flash[:notice]
    assert_equal 'paid', assigns(:payment).status
  end

  test "should fail to pay unscheduled payment" do
    stub_request(:post, PY_URL).to_return(:body => File.open("test/stubs/charge.json"))

    post :pay, params: { id: payments(:refunded).id }

    assert_redirected_to payments_path
    assert_equal 'Failed to pay payment.', flash[:alert]
  end
end
