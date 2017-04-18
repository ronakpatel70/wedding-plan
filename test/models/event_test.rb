require 'test_helper'

class EventTest < ActiveSupport::TestCase

  # Scopes

  test 'future should include events created less than 18 months ago' do
    assert_equal 3, Event.future.count
  end

  test 'past should include events created more than 18 months ago' do
    assert_equal 4, Event.past.count
  end

  test 'tbd should include events without date' do
    assert_equal 2, Event.tbd.count
  end

  test 'rewards should include events where joined_rewards_at is not null' do
    assert_equal 5, Event.rewards.count
  end

  # Methods

  test 'to_s should return semiformal date' do
    assert_equal 'December 31, 2016', events(:one).to_s
    assert_equal 'TBD', events(:six).to_s
  end

  test 'rewards should return rewards status' do
    assert events(:one).rewards?
    assert_not events(:four).rewards?
  end

  test 'rewards_deadline should return 45 days before event date' do
    assert_equal Date.parse('2016-11-16'), events(:one).rewards_deadline
    assert_equal nil, events(:six).rewards_deadline
  end

  test 'rewards_points_needed should return difference to next tier' do
    assert_equal 3, events(:one).rewards_points_needed
    assert_equal 0, events(:three).rewards_points_needed
    assert_equal 4, events(:four).rewards_points_needed
  end

  test 'rewards_tier should return correct tier number' do
    assert_equal 2, events(:one).rewards_tier
    assert_equal 3, events(:three).rewards_tier
    assert_equal 1, events(:four).rewards_tier
  end

end
