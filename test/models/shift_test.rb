require 'test_helper'

class ShiftTest < ActiveSupport::TestCase

  # Callbacks

  test "should reset status when changing times" do
    shift = shifts(:one)

    shift.update(notes: "more notes")
    assert_equal "confirmed", shift.status

    shift.update(start_time: "2015-10-29 12:30:00")
    assert_equal "pending", shift.status
  end

  # Validations

  test "should not save without user" do
    shift = Shift.new(position: positions(:door_host), show: shows(:one))
    assert_not shift.save
  end

  test "should not save without position" do
    shift = Shift.new(user: users(:dylan), show: shows(:one))
    assert_not shift.save
  end

  test "should not save without show" do
    shift = Shift.new(user: users(:dylan), position: positions(:door_host))
    assert_not shift.save
  end

  # Scopes

  test "on date" do
    shifts = Shift.on(Date.new(2015, 10, 29))
    assert_equal 2, shifts.count
  end

  # Methods

  test "duration" do
    assert_equal 210, shifts(:two).duration
  end

  test "time_worked" do
    assert_equal 1.8, shifts(:one).time_worked
    assert_equal 0, shifts(:two).time_worked
  end

end
