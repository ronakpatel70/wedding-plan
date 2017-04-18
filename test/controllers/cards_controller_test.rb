require "test_helper"

class CardsControllerTest < BaseTest
  setup do
    @card = cards(:one)
    stub_request(:any, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c").to_return(:body => File.open("test/stubs/customer.json"))
    stub_request(:post, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources").to_return(:body => File.open("test/stubs/card.json"))
  end

#   test "should get index" do
#     get :index, params: { user_id: users(:dylan) }
#     assert_response :success
#     assert_not_nil assigns(:cards)
#
#     get :index, vendor_id: vendors(:one)
#     assert_response :success
#     assert_not_nil assigns(:cards)
#   end

  test "should get new" do
    get :new, params: { user_id: users(:dylan) }
    assert_response :success

    get :new, params: { vendor_id: vendors(:one) }
    assert_response :success
  end

  test "should show card" do
    get :show, params: { id: cards(:one) }
    assert_response :success
  end

  test "should create card" do
    assert_difference("Card.count", 1) do
      post :create, params: { card: { stripe_token: "tk_123" }, user_id: users(:dylan) }
    end
    assert_redirected_to user_path(assigns(:card).owner)

    assert_difference("Card.count") do
      post :create, params: { card: { stripe_token: "tk_123" }, vendor_id: vendors(:one) }
    end
    assert_redirected_to vendor_path(assigns(:card).owner)
  end

  test "should destroy card" do
    assert_difference("Card.deleted.count", 1) do
      delete :destroy, params: { id: @card }
    end

    assert_redirected_to @card.owner
  end
end
