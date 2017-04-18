require 'test_helper'

class TransfersControllerTest < BaseTest
  setup do
    @transfer = transfers(:one)
    stub_request(:post, "https://api.stripe.com/v1/transfers").to_return(:body => File.open('test/stubs/transfer.json'))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transfers)
  end

  test "should get new" do
    get :new, params: { user_id: users(:dylan), show_id: shows(:one) }
    assert_response :success
  end

  test "should create transfer" do
    assert_difference('Transfer.count') do
      post :create, params: { transfer: { user_id: users(:dylan), amount: 100, description: "Wedding Expo staff payment" }, show_id: shows(:one) }
    end

    assert_redirected_to timesheet_show_shifts_url(shows(:one).id)
  end

  test "should destroy transfer" do
    assert_difference('Transfer.count', -1) do
      delete :destroy, params: { id: @transfer }
    end

    assert_redirected_to transfers_path
  end
end
