require 'test_helper'

class Admin::VendorMailerTest < ActionMailer::TestCase
  test "should send booth_updated" do
    booth = booths(:one)
    booth.update(size: "3x10", status: :denied)
    mail = Admin::VendorMailer.booth_updated(booth).deliver_now!

    assert_equal ["dylan@waits.io"], mail.to
    assert_match "- Size changed from 6x6 to 3x10", mail.body.to_s
    assert_match "- Status changed from approved to denied", mail.body.to_s
  end

  test "should send upcoming_payment" do
    payment = payments(:scheduled)
    mail = Admin::VendorMailer.upcoming_payment(payment).deliver_now!

    assert_equal ["info@winecountrybride.com"], mail.to
    assert_match "payment of $1.00", mail.body.to_s
  end

  test "should send declined_payment" do
    payment = payments(:declined)
    mail = Admin::VendorMailer.declined_payment(payment).deliver_now!

    assert_equal ["info@winecountrybride.com"], mail.to
    assert_match "payment of $1.00", mail.body.to_s
  end
end
