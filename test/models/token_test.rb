require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test "should generate token" do
    user = users(:dylan)
    token = Token.generate(user.id)

    assert_equal 44, token.id.length
    assert_equal user, token.user
    assert_in_delta (Time.now + 30.days).to_i, token.expires_at.to_i, 5
  end

  test "should generate unique tokens" do
    user = users(:dylan)
    t1 = Token.generate(user.id)
    t2 = Token.generate(user.id)
    t3 = Token.generate(user.id)

    assert t1.id != t2.id
    assert t2.id != t3.id
    assert t1.id != t3.id
  end
end
