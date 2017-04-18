require 'test_helper'

class PackageTest < ActiveSupport::TestCase

  # Validations

  test "should not save without show" do
    package = Package.new(name: "Grand Prize")
    assert_not package.save
  end

  test "should redeem package" do
    package = packages(:one)
    package.winner = users(:megan)
    assert  package.save
  end

  test "should not redeem package for winner not in show" do
    package = packages(:one)
    package.winner = users(:dylan)
    assert_not package.save
  end

  test "should not redeem more than one package per winner" do
    package = packages(:one)
    package.winner = users(:megan)
    assert package.save

    package = packages(:two)
    package.winner = users(:megan)
    assert_not package.save
  end

  test "should redeem multiple non-cake packages" do
    package = packages(:one)
    package.winner = users(:megan)
    assert package.save

    package = packages(:highlighted)
    package.winner = users(:megan)
    assert package.save

    package = packages(:grand)
    package.winner = users(:megan)
    assert package.save
  end

  # Methods

  test "to_s should return name or empty string" do
    assert_equal "", packages(:one).to_s
  end

  test "value should return sum of prize values" do
    assert_equal 2000, packages(:one).value
  end

end
