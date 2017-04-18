require "test_helper"

class WebhooksControllerTest < ActionController::TestCase
  test "should post successful charge" do
    chg = {id: "ch_1234", customer: "cus_79ZU2mLycWhs6c", amount: 100,
      created: Time.now.to_i, description: "Test charge",
      source: {id: "card_16vGqV2RDM5ZUbA00snzKzqd"}}

    assert_difference("Payment.count", 1) do
      post :stripe, params: { type: "charge.succeeded", data: {object: chg} }
    end

    assert_response :no_content
    assert_in_delta Time.now.to_i, Payment.last.captured_at.to_i, 1
  end

  test "should post duplicate charge" do
    chg = {id: payments(:one).stripe_charge_id, customer: "cus_79ZU2mLycWhs6c",
      amount: 100, created: Time.now.to_i, description: "Duplicate charge",
      source: {id: "card_16vGqV2RDM5ZUbA00snzKzqd"}}

    assert_difference("Payment.count", 0) do
      post :stripe, params: { type: "charge.succeeded", data: {object: chg} }
    end

    assert_response :no_content
  end

  test "should post subscription update" do
    next_month = (Time.now + 30.days).to_i
    sub = {id: "sub_83JcItwbPyAcvJ", status: "past_due", current_period_end: next_month}
    post :stripe, params: { type: "customer.subscription.updated", data: {object: sub} }

    assert_response :no_content
    assert_equal "past_due", subscriptions(:active).status
    assert_in_delta next_month, subscriptions(:active).current_period_end.to_i, 1
  end

  test "should post invalid subscription" do
    sub = {id: "bad_subscription_id"}
    post :stripe, params: { type: "customer.subscription.updated", data: {object: sub} }

    assert_response :bad_request
  end

  test "should post card update" do
    card = {id: "card_16vGqV2RDM5ZUbA00snzKzqd", last4: "0303", exp_month: 10, exp_year: 2022}
    post :stripe, params: { type: "customer.source.updated", data: {object: card} }

    assert_response :success
    assert_equal "0303", cards(:one).last4
    assert_equal Date.new(2022, 10), cards(:one).expiry
  end

  test "should post with nil data" do
    post :stripe, params: { type: "charge.succeeded", data: {} }

    assert_response :bad_request
  end

  test "should post unknown event type" do
    post :stripe, params: { type: "something.else" }

    assert_response :bad_request
  end

  test "should post sms message" do
    assert_difference("Text.count") do
      post :twilio, params: { "From" => "+17075555555", "To" => "+17078760001", "Body" => "Hello, world!" }
    end

    assert_response :success
  end

  test "should post sms message with unknown sender" do
    assert_difference("Text.count") do
      post :twilio, params: { "From" => "+17075555555", "To" => "+17078760001", "Body" => "Hello, world!" }
    end

    assert_response :success
  end
end
