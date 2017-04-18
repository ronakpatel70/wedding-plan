require 'test_helper'

class AddressTest < ActiveSupport::TestCase

  # Validations

  test 'should save valid address' do
    address = Address.new street: '123 Main St', city: 'Windsor', state: 'CA', zip: '00000'
    assert address.save
  end

  test 'should not save invalid state' do
    address = Address.new street: '123 Main St', city: 'Windsor', state: 'Wisconsin', zip: '00000'
    assert_not address.save
  end

  test 'should not save invalid zip' do
    address = Address.new street: '123 Main St', city: 'Windsor', state: 'CA', zip: '0000O'
    assert_not address.save
  end

  # Methods

  test 'to_s should return full address' do
    assert_equal "590 Shagbark St\nWindsor, CA 95492", addresses(:one).to_s
  end

end
