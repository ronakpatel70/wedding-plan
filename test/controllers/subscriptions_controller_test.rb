require 'test_helper'

class SubscriptionsControllerTest < BaseTest
  setup do
    stub_request(:get, CU_URL).to_return(:body => File.open('test/stubs/customer.json'))
    stub_request(:post, "#{CU_URL}/subscriptions").to_return(:body => File.open('test/stubs/subscription.json'))
    stub_request(:get, "#{CU_URL}/subscriptions/sub_83JcItwbPyAcvJ").to_return(:body => File.open('test/stubs/subscription.json'))
    stub_request(:any, SUB_URL).to_return(:body => File.open("test/stubs/subscription.json"))
    stub_request(:delete, "#{SUB_URL}/discount").to_return(:body => File.open('test/stubs/subscription.json'))
    @subscription = subscriptions(:active)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subscriptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subscription" do
    assert_difference('Subscription.count') do
      post :create, params: { subscription: { vendor_id: vendors(:one), plan: 'rewards_yearly', coupon: 'show_discount_yearly' } }
    end

    assert_redirected_to :subscriptions
  end

  test "should show subscription" do
    get :show, params: { id: @subscription }
    assert_response :success
  end

  test "should update subscription" do
    patch :update, params: { id: @subscription, subscription: { coupon: '' } }
    assert_redirected_to :subscriptions

    patch :update, params: { id: @subscription, subscription: { plan: 'rewards_yearly', coupon: 'show_discount_yearly' } }
    assert_redirected_to :subscriptions
  end

  test "should pay invoice" do
    stub_request(:get, CU_INVOICE_URL).to_return(:body => File.open("test/stubs/invoices.json"))
    stub_request(:post, PAY_SUB_URL).to_return(:body => File.open("test/stubs/invoice.json"))

    post :pay, params: { id: subscriptions(:past_due) }
    assert_redirected_to :subscriptions
    assert_equal 'Subscription was successfully paid.', flash[:notice]
  end

  test "should fail to pay invoice" do
    stub_request(:get, CU_INVOICE_URL).to_return(:body => File.open("test/stubs/invoices.json"))
    stub_request(:post, PAY_SUB_URL).to_return(:body => File.open("test/stubs/open_invoice.json"))

    post :pay, params: { id: subscriptions(:past_due) }
    assert_redirected_to :subscriptions
    assert_equal 'Failed to pay subscription.', flash[:alert]
  end

  test "should destroy subscription" do
    assert_difference('Subscription.canceled.count', 1) do
      delete :destroy, params: { id: @subscription }
    end

    assert_redirected_to :subscriptions
  end
end
