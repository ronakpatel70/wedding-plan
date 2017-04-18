require 'test_helper'

class PositionTest < ActiveSupport::TestCase

  # Callbacks

  test 'should destroy position and associated shifts' do
    position = positions(:door_host)
    shift = shifts(:one)

    position.destroy
    assert position.destroyed?
    assert position.shifts.empty?
  end

  # Validations

  test 'should save valid position' do
    position = Position.new(name: 'Test', short_description: 'test position', quantity: 1)
    assert position.save
  end

  test 'should not save without name' do
    position = Position.new(short_description: 'test position', quantity: 1)
    assert_not position.save
  end

  test 'should not save without short description' do
    position = Position.new(name: 'Test', quantity: 1)
    assert_not position.save
  end

  test 'should not save negative quantity' do
    position = Position.new(name: 'Test', short_description: 'test position', quantity: 0)
    assert_not position.save
  end

  # Scopes

  test 'active scope' do
    assert_equal 2, Position.active.count
    assert_equal 1, Position.inactive.count
  end

end
