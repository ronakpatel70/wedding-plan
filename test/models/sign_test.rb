require 'test_helper'

class SignTest < ActiveSupport::TestCase

  setup do
    @sign = signs(:one)
  end

  # Associations

  test "vendor association" do
    assert_equal vendors(:one), @sign.vendors[0]
  end

  test "booth association" do
    assert_equal booths(:one), @sign.booths.where(show: shows(:two))[0]
  end

  # Scopes

  test "blank should return signs without back" do
    assert_equal 1, Sign.blank.count
  end

  # Methods

  test "to_s should return hash and id" do
    assert_equal "Sign ##{@sign.id}", @sign.to_s
  end

  test "text should return front and back text" do
    assert_equal "Wine Country Bride", @sign.text
    assert_equal "Premier Productions | Ellington Hall", signs(:two).text
  end

end
