require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do
    vendors(:two).update(show_statuses: {shows(:one).id => "lead", shows(:two).id => "interested"})
  end

  # Callbacks

  test "should destroy vendor and dependent objects" do
    vendor = vendors(:two)
    vendor.destroy

    assert vendor.destroyed?, "Vendor was not destroyed"
    [:points, :booths, :offers, :prizes, :testimonials, :tickets].each do |x|
      assert(vendor.send(x).empty?, "Associated #{x} were not destroyed")
    end
  end

  test "should update stripe customer" do
    stub_request(:any, CU_URL).to_return(:body => File.open("test/stubs/customer.json"))

    vendor = vendors(:one)
    vendor.default_card_id = cards(:wcb_two).id
    vendor.email = "new.business@example.com"
    vendor.name = "My New Business Name"

    assert vendor.save
    assert_requested :post, CU_URL
  end

  test "should not update customer without stripe id" do
    vendor = vendors(:two)
    vendor.email = "new.business@example.com"

    assert vendor.save
  end

  # Validations

  test "should save valid vendor" do
    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel", website: "https://wcb123.co/index.html"
    assert vendor.save
  end

  test "should save website with dashes" do
    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel", website: "http://goo-gle.com"
    assert vendor.save
  end

  test "should not save duplicate name" do
    vendor = Vendor.new name: "Wine Country Bride", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel"
    assert_not vendor.save
  end

  test "should not save long name" do
    vendor = Vendor.new name: "This is a really long business name that is too long", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel"
    assert_not vendor.save
  end

  test "should not save invalid email" do
    vendor = Vendor.new name: "Test", email: "test@example", phone: "707.544.3695", contact: "Cirkl", industry: "apparel"
    assert_not vendor.save
  end

  test "should not save invalid phone" do
    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.", contact: "Cirkl", industry: "apparel"
    assert_not vendor.save

    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707888-", contact: "Cirkl", industry: "apparel"
    assert_not vendor.save
  end

  test "should not save invalid website" do
    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel", website: "www.wine.com"
    assert_not vendor.save

    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel", website: "http://wine,com"
    assert_not vendor.save

    vendor = Vendor.new name: "Test", email: "test@example.com", phone: "707.544.3695", contact: "Cirkl", industry: "apparel", website: "http:/wine,com"
    assert_not vendor.save
  end

  # Scopes

  test "with_status" do
    assert_equal 1, Vendor.with_status(shows(:one).id, "lead").count
    assert_equal 1, Vendor.with_status(shows(:two).id, "interested").count
    assert_equal 0, Vendor.with_status(shows(:one).id, "awaiting_application").count
  end

  # Methods

  test "normalize_phone should strip all non-digit characters" do
    vendor = Vendor.create name: "Test", email: "test@example.com", phone: "707.123.4567", cell_phone: "(707) 123-4567", contact: "Cirkl", industry: "apparel"
    assert_equal "7071234567", vendor.phone
    assert_equal "7071234567", vendor.cell_phone
  end

  test "should merge vendors" do
    vendor = vendors(:one)
    into = vendors(:two)
    vendor.merge(into)
    vendor.reload

    assert into.destroyed?
    assert_equal 4, vendor.points.length
    assert_equal 5, vendor.booths.length
    assert_equal 3, vendor.prizes.length
    assert_equal 2, vendor.signs.length
    assert_equal 2, vendor.testimonials.length
    assert_equal [tickets(:vendor_free_pass)], vendor.tickets
    assert_equal [users(:dylan), users(:megan)], vendor.users
    assert_equal "https://www.facebook.com", vendor.facebook
    assert_not_equal "https://winecountrybridez.com", vendor.website
  end

  test "should not merge vendor with active subscription" do
    vendor = vendors(:two)
    into = vendors(:one)

    assert_not vendor.merge(into)
    assert_not into.destroyed?
    assert_equal [users(:megan)], vendor.users
  end

  test "should not merge vendor into itself" do
    vendor = vendors(:one)

    assert_not vendor.merge(vendor)
    assert_not vendor.destroyed?
  end

end
