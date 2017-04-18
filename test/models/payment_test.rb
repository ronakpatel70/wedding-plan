require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  setup do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(:body => File.open("test/stubs/token.json"))
    stub_request(:post, "https://api.stripe.com/v1/refunds").to_return(:body => File.open("test/stubs/refund.json"))
  end

  # Validations

  test "should create valid payment" do
    payment = Payment.new(method: :cash, amount: 100, description: "Test Payment", payer: users(:dylan))
    assert payment.save
    assert_in_delta Time.now.to_i, payment.captured_at.to_i, 1
  end

  test "should not save without payer" do
    payment = Payment.new(method: :cash, amount: 100, description: "Test Payment")
    assert_not payment.save
  end

  test "should not refund negative amount" do
    payment = payments(:one)
    payment.refund_amount = -10
    assert_not payment.save
  end

  test "should not refund amount larger than total" do
    payment = payments(:one)
    payment.refund_amount = 200
    assert_not payment.save
  end

  test "should fail on past scheduled_for" do
    payment = Payment.new(method: :card, card: cards(:one), amount: 100, description: "Test Payment", payer: users(:dylan), scheduled_for: Date.today)
    assert_not payment.save
  end

  test "should fail on scheduled payment without card" do
    payment = Payment.new(method: :card, amount: 100, description: "Test Payment", payer: users(:dylan), scheduled_for: Date.today + 1.day)
    assert_not payment.save
  end

  test "should fail on cash payment with card" do
    payment = Payment.new(method: :cash, card: cards(:one), amount: 100, description: "Test", payer: users(:dylan))
    assert_not payment.save
  end

  # Callbacks

  test "should charge card" do
    payment = Payment.new(method: :card, card: cards(:one), amount: 100, description: "Test Payment", payer: users(:dylan))
    assert payment.save
    assert payment.paid?
    assert_in_delta Time.now.to_i, payment.captured_at.to_i, 1
  end

  test "should refund charge" do
    payment = payments(:one)
    payment.refund_amount = 100
    assert payment.save
    assert payment.refunded?
  end

  test "should partially refund charge" do
    payment = payments(:two)
    payment.refund_amount = 2500
    assert payment.save
    assert_not payment.refunded?
  end

  test "should schedule payment" do
    payment = Payment.new(method: :card, card: cards(:one), amount: 100, description: "Test Payment", payer: users(:dylan), scheduled_for: Date.today + 30.days)
    assert payment.save
    assert payment.scheduled?
    assert_not payment.refundable?
    assert_nil payment.captured_at
  end

  test "should update booth balance when created" do
    booth = booths(:no_amenities)
    assert_difference("booth.reload.balance", -300) do
      booth.payments.create!(method: :cash, amount: 300, description: "Test", payer: vendors(:one))
    end
  end

  test "should update booth balance when refunded" do
    booth = booths(:one)
    assert_difference("booth.reload.balance", 20000) do
      payments(:two).update(refund_amount: 20000)
    end
  end

  test "should update booth balance when partially refunded" do
    booth = booths(:one)
    assert_difference("booth.reload.balance", 3000) do
      payments(:two).update(refund_amount: 3000)
    end
    assert_difference("booth.reload.balance", 2000) do
      payments(:two).update(refund_amount: 5000)
    end
    assert_difference("booth.reload.balance", 15000) do
      payments(:two).update(refund_amount: 20000)
    end
  end

  test "should update booth balance when captured" do
    booth = booths(:two)
    assert_difference("booth.reload.balance", -100) do
      payments(:scheduled).charge_now!(save: true)
    end
  end

  test "should update booth balance when destroyed" do
    booth = booths(:one)
    assert_difference("booth.reload.balance", 20000) do
      payments(:two).destroy! && sleep(0)
    end
  end

  # Methods

  test "charge_now!" do
    payment = payments(:scheduled)
    assert payment.charge_now!(save: true)
    assert payment.paid?
    assert_not_nil payment.stripe_charge_id
    assert_in_delta Time.now.to_i, payment.captured_at.to_i, 1
    assert_nil payment.scheduled_for
  end

  test "charge_now! should not charge card twice" do
    payment = payments(:one)
    assert_not payment.charge_now!(save: true)
  end

  test "amount_paid" do
    assert_equal 100, payments(:one).amount_paid
    assert_equal 20000, payments(:two).amount_paid
    assert_equal 0, payments(:declined).amount_paid
    assert_equal 0, payments(:scheduled).amount_paid
    assert_equal 0, payments(:refunded).amount_paid
    assert_equal 2500, payments(:partial_refund).amount_paid
  end

  test "refundable" do
    assert payments(:one).refundable?
    assert_not payments(:declined).refundable?
    assert_not payments(:scheduled).refundable?
    assert_not payments(:refunded).refundable?
  end

end
