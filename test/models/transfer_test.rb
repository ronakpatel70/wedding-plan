require 'test_helper'

class TransferTest < ActiveSupport::TestCase

  setup do
    stub_request(:post, "https://api.stripe.com/v1/transfers").to_return(:body => File.open('test/stubs/transfer.json'))
  end

  # Validations

  test 'should create valid transfer' do
    transfer = Transfer.new user: users(:dylan), description: "Wedding Expo staff transfer", amount: 100
    assert transfer.save
    assert_not_nil transfer.stripe_transfer_id
  end

  test 'should not save negative amount' do
    transfer = Transfer.new user: users(:dylan), description: "Wedding Expo staff transfer", amount: -100
    assert_not transfer.save
  end

  test 'should not save without description' do
    transfer = Transfer.new user: users(:dylan), amount: 100
    assert_not transfer.save
  end

  test 'should not save without user' do
    transfer = Transfer.new description: "Wedding Expo staff transfer", amount: 100
    assert_not transfer.save
  end

  test 'should not save user without stripe_recipient_id' do
    transfer = Transfer.new user: users(:megan), description: "Wedding Expo staff transfer", amount: 100
    assert_not transfer.save
  end

end
