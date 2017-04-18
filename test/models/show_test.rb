require 'test_helper'

class ShowTest < ActiveSupport::TestCase

  # Callbacks

  test "should destroy user and dependent objects" do
    show = shows(:three)
    show.destroy

    assert show.destroyed?, "Show was not destroyed"
    [:booths, :job_applications, :prizes, :packages, :shifts, :tickets].each do |x|
      assert(show.send(x).empty?, "Associated #{x} were not destroyed")
    end
  end

  test "should not destroy show with tickets" do
    show = shows(:one)
    show.destroy
    assert_not show.destroyed?, "Show was not destroyed"
  end

  # Validations

  test "create should combine date with start and end times" do
    show = Show.create start: "2013-02-12 12:00", end: "2013-02-12 17:00", location: locations(:sr)
    assert_equal DateTime.parse("2013-02-12 12:00:00 #{Time.zone}"), show.start
    assert_equal DateTime.parse("2013-02-12 17:00:00 #{Time.zone}"), show.end
  end

  test "should not save without location" do
    show = Show.new(start: "2013-02-12 12:00", end: "2013-02-12 17:00")
    assert_not show.save
  end

  # Scopes

  test "previous should include previous show" do
    show = locations(:sr).shows.previous
    assert_equal Date.parse("2015-09-30"), show.date
  end

  test "next should include next show" do
    show = locations(:sr).shows.next
    assert_equal shows(:next), show
  end

  test "following should include show after next" do
    show = locations(:sr).shows.following
    assert_equal shows(:following), shows(:following)
  end

  test "recent should include most recent show within 45 days" do
    recent = locations(:sr).shows.recent[0]
    prev = locations(:sr).shows.previous
    assert prev.date < Date.today - 45.days || recent && Date.parse("2015-09-20") == recent.date
  end

  # Methods

  test "to_s should return semiformal date" do
    assert_equal "January 21, 2017", shows(:seventeen).to_s
  end

  test "update should combine date with start and end times" do
    show = shows(:one)
    show.update start: "2015-01-01 11:00", end: "2015-01-01 16:00"
    assert_equal DateTime.parse("2015-01-01 11:00:00 #{Time.zone}"), show.start
    assert_equal DateTime.parse("2015-01-01 16:00:00 #{Time.zone}"), show.end
  end

  test "current_ticket_price should return ticket price based on date" do
    assert_equal 2000, shows(:today).current_ticket_price
    assert_equal 1500, shows(:next).current_ticket_price
    assert_equal 1500, shows(:seventeen).current_ticket_price
    assert_equal 1000, shows(:two).current_ticket_price
    assert_equal 1000, shows(:following).current_ticket_price
  end

  test "payment_deadline should return show date minus 30 days" do
    assert_equal Date.parse("2016-12-22"), shows(:seventeen).payment_deadline
  end

  test "next should return show after target" do
    assert_equal shows(:following), shows(:next).next
  end

  test "previous should return show before target" do
    assert_equal shows(:next), shows(:following).previous
  end

end
