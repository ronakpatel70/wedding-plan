require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  # Validations

  test "should save valid role" do
    role = Role.new(user: users(:megan), type: :admin)
    assert role.save
  end

  test "should not save without user" do
    role = Role.new(type: :admin)
    assert_not role.save
  end

  test "should not save duplicate user and type" do
    role = Role.new(user: users(:dylan), type: :admin)
    assert_not role.save
  end

end
