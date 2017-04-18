require 'test_helper'

class FeeTest < ActiveSupport::TestCase

  # Validations

  test 'should create valid fee' do
    fee = Fee.new(amount: 100, description: 'Test Fee', booth: booths(:one))
    assert fee.save
  end

  test 'should not save without description' do
    fee = Fee.new(amount: 100, booth: booths(:one))
    assert_not fee.save
  end

  test 'should not save without booth' do
    fee = Fee.new(amount: 100, description: 'Test fee')
    assert_not fee.save
  end

  # Callbacks

  test 'should update booth total when created' do
    booth = booths(:one)

    assert_difference('booth.reload.total', 2000) do
      booth.fees.create!(amount: 2000, description: 'Test Fee')
    end

    assert_difference('booth.reload.total', -500) do
      booth.fees.create!(amount: -500, description: 'Test Discount')
    end
  end

  test 'should update booth total when destroyed' do
    assert_difference('booths(:one).reload.total', -5000) do
      fees(:one).destroy && sleep(0)
    end

    assert_difference('booths(:one).reload.total', 10000) do
      fees(:two).destroy && sleep(0)
    end
  end

end
