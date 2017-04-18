require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    stub_request(:get, CU_URL).to_return(:body => File.open("test/stubs/customer.json"))
    stub_request(:get, "#{CU_URL}/subscriptions/sub_83JcItwbPyAcvJ").to_return(:body => File.open("test/stubs/subscription.json"))
    @vendor = vendors(:one)
  end

  # Validations

  test "should create valid subscription" do
    stub_request(:post, "#{CU_URL}/subscriptions").to_return(:body => File.open("test/stubs/subscription.json"))
    subscription = Subscription.new(vendor_id: @vendor.id, plan: "rewards_yearly", coupon: "show_discount")
    assert subscription.save
    assert_equal "active", subscription.status
    assert_not_nil subscription.stripe_subscription_id
    assert_equal Date.parse("2017-03-09"), subscription.current_period_end.to_date
  end

  test "should create subscription with trial" do
    stub_request(:post, "#{CU_URL}/subscriptions").to_return(:body => File.open("test/stubs/trial_subscription.json"))
    subscription = Subscription.new(vendor_id: @vendor.id, plan: "rewards_yearly", coupon: "show_discount", trial_end: "2021-04-30")
    assert subscription.save
    assert_equal "trialing", subscription.status
    assert_not_nil subscription.stripe_subscription_id
    assert_equal Date.parse("2021-04-30"), subscription.current_period_end.to_date
  end

  test "should not save without vendor" do
    subscription = Subscription.new(vendor_id: nil, plan: "rewards_yearly", coupon: "show_discount")
    assert_not subscription.save
  end

  test "should not save without plan" do
    subscription = Subscription.new(vendor: @vendor)
    assert_not subscription.save
  end

  test "should not save duplicate vendor and plan" do
    subscription = Subscription.new(vendor: @vendor, plan: "rewards_monthly")
    assert_not subscription.save
  end

  # Methods

  test "should change plan" do
    stub_request(:post, "#{SUB_URL}").to_return(:body => File.open("test/stubs/subscription.json"))
    subscription = subscriptions(:active)
    subscription.plan = "rewards_yearly"
    subscription.coupon = "show_discount_yearly"
    assert subscription.save
  end

  test "should change coupon" do
    stub_request(:delete, "#{SUB_URL}/discount").to_return(:body => File.open("test/stubs/subscription.json"))
    stub_request(:post, "#{SUB_URL}").to_return(:body => File.open("test/stubs/subscription.json"))
    subscription = subscriptions(:active)
    subscription.coupon = nil
    assert subscription.save
  end

  test "should cancel subscription" do
    stub_request(:delete, "#{SUB_URL}").to_return(:body => File.open("test/stubs/subscription.json"))
    subscription = subscriptions(:active)
    assert subscription.destroy
    assert subscription.canceled?
  end

  test "should pay invoice" do
    stub_request(:get, CU_INVOICE_URL).to_return(:body => File.open("test/stubs/invoices.json"))
    stub_request(:post, PAY_SUB_URL).to_return(:body => File.open("test/stubs/invoice.json"))

    s = subscriptions(:past_due)
    assert s.pay
  end

  test "should fail to pay invoice" do
    stub_request(:get, CU_INVOICE_URL).to_return(:body => File.open("test/stubs/invoices.json"))
    stub_request(:post, PAY_SUB_URL).to_return(:body => File.open("test/stubs/open_invoice.json"))

    s = subscriptions(:past_due)
    assert_not s.pay
  end

  test "should not pay active/canceled invoice" do
    [:active, :canceled].each { |s| assert_not subscriptions(s).pay, "Expected pay to return false" }
  end
end
