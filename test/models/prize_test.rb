require 'test_helper'

class PrizeTest < ActiveSupport::TestCase

  # Validations

  test "should save valid prize" do
    prize = Prize.new(show: shows(:two), vendor: vendors(:one), name: "Test Prize", quantity: 25, value: 1000, rules: "A bunch of rules.", type: "discount")
    assert prize.save
  end

  test "should not save without show" do
    prize = Prize.new(vendor: vendors(:one), name: "Test Prize", quantity: 25, value: 1000, rules: "A bunch of rules.", type: "discount")
    assert_not prize.save
  end

  test "should not save without vendor" do
    prize = Prize.new(show: shows(:two), name: "Test Prize", quantity: 25, value: 1000, rules: "A bunch of rules.", type: "discount")
    assert_not prize.save
  end

  test "should not save quantity over 50" do
    prize = Prize.new(show: shows(:two), vendor: vendors(:one), name: "Test Prize", quantity: 51, value: 1000, rules: "A bunch of rules.", type: "discount")
    assert_not prize.save
  end

  test "should not save value under 1000" do
    prize = Prize.new(show: shows(:two), vendor: vendors(:one), name: "Test Prize", quantity: 25, value: 900, rules: "A bunch of rules.", type: "discount")
    assert_not prize.save
  end

  test "should not save name over 50 characters" do
    prize = Prize.new(show: shows(:two), vendor: vendors(:one), name: "toy boat " * 5, quantity: 25, value: 1000, type: "discount")
    assert_not prize.save
  end

  # Methods

  test "to_s should return name" do
    assert_equal "Cheap Prize", prizes(:one).to_s
  end

  test "full_name should return name with value" do
    assert_equal "Cheap Prize ($10)", prizes(:one).full_name
  end

end
