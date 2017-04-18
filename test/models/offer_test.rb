require 'test_helper'

class OfferTest < ActiveSupport::TestCase

  # Validations

  test "should save valid offer" do
    offer = Offer.new(vendor: vendors(:one), tier: 3, type: :dollar, value: 150, name: "$150 off my services")
    assert offer.save
  end

  test "should not save without vendor" do
    offer = Offer.new(tier: 3, type: :dollar, value: 150, name: "$150 off my services")
    assert_not offer.save
  end

  test "should not save without name" do
    offer = Offer.new(vendor: vendors(:one), tier: 3, type: :dollar, value: 150)
    assert_not offer.save
  end

  test "should not save non-numeric value" do
    offer = Offer.new(vendor: vendors(:one), tier: 3, type: :dollar, value: "haha", name: "$150 off my services")
    assert_not offer.save
  end

  test "should not save duplicate tier" do
    offer = Offer.new(vendor: vendors(:one), tier: 2, type: :dollar, value: 150, name: "$150 off my services")
    assert_not offer.save
  end

end
