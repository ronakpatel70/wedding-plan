require 'test_helper'

class PointTest < ActiveSupport::TestCase

  setup do
    @event = events(:four)
    @vendor = vendors(:one)
  end

  # Callbacks

  test 'should add point to event on create' do
    assert_difference('@event.rewards_points') do
      point = Point.new(vendor: @vendor, event: @event, status: 'confirmed')
      point.save
    end
  end

  test 'should subtract point from event on destroy' do
    event = events(:one)
    assert_difference('event.rewards_points', -1) do
      event.points.first.destroy
    end
  end

  # Validations

  test 'should not create duplicate point' do
    point = Point.new(vendor: @vendor, event: events(:one), status: 'confirmed')
    assert_not point.save
  end

  test 'should not create point without vendor' do
    point = Point.new(event: @event, status: 'confirmed')
    assert_not point.save
  end

  # Scopes

  test 'past should select points for events more than 45 days past' do
    assert_equal 1, Point.past.count
  end

end
