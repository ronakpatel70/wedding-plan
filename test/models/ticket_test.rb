require 'test_helper'

class TicketTest < ActiveSupport::TestCase

  setup do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(:body => File.open("test/stubs/token.json"))
    stub_request(:post, "https://api.stripe.com/v1/refunds").to_return(:body => File.open("test/stubs/refund.json"))
  end

  # Validations

  test "should save valid ticket" do
    ticket = Ticket.new show: shows(:one), user: users(:dylan), quantity: 3, payment_method: :card
    assert ticket.save
    assert_equal "3 Wedding Expo tickets", ticket.payment.description
  end

  test "should not save negative quantity" do
    ticket = Ticket.new show: shows(:one), user: users(:dylan), quantity: -1, payment_method: :card
    assert_not ticket.save
  end

  test "should not save without user" do
    ticket = Ticket.new(show: shows(:one), quantity: 1, payment_method: :card)
    assert_not ticket.save
  end

  test "should not save without show" do
    ticket = Ticket.new(user: users(:dylan), quantity: 1, payment_method: :card)
    assert_not ticket.save
  end

  test "should not save with invalid card" do
    ticket = Ticket.new show: shows(:one), user: users(:megan), quantity: 3, payment_method: :card
    assert_not ticket.save
  end

  # methods

  test "should refund paid ticket" do
    ticket = tickets(:one)
    ticket.destroy
    assert ticket.payment.refunded?
  end

end
