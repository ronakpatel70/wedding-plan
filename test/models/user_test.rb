require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @dylan = users(:dylan)
  end

  # Callbacks

  test "should destroy user and dependent objects" do
    user = users(:megan)
    user.destroy

    assert user.destroyed?, "User was not destroyed"
    assert user.address.destroyed?, "Address was not destroyed"
    [:cards, :job_applications, :roles, :shifts, :shows, :tickets, :vendors].each do |x|
      assert(user.send(x).empty?, "Associated #{x} were not destroyed")
    end
  end

  test "should not destroy user with tickets" do
    user = users(:dylan)
    user.destroy
    assert_not user.destroyed?, "User was destroyed"
  end

  test "should update default card" do
    stub_request(:any, CU_URL).to_return(:body => File.open("test/stubs/customer.json"))

    user = users(:dylan)
    user.default_card_id = cards(:two).id

    assert user.save
    assert_requested :post, CU_URL
  end

  test "should update recipient" do
    stub_request(:any, RCP_URL).to_return(:body => File.open("test/stubs/recipient.json"))

    user = users(:dylan)
    user.first_name = "Yolo"

    assert user.save
    assert_requested :post, RCP_URL
  end

  test "should not update customer without stripe id" do
    user = users(:megan)
    user.email = "new.user@example.com"

    assert user.save
  end

  # Validations

  test 'should save valid user' do
    user = User.new first_name: 'John', last_name: 'Smith', email: 'john@example.com', phone: '(707) 555-1234', event_role: 'groom'
    assert user.save
  end

  test 'should not save duplicate email' do
    user = User.new first_name: 'John', last_name: 'Smith', email: 'dylan@waits.io'
    assert_not user.save

    user = User.new first_name: 'John', last_name: 'Smith', email: 'Dylan@waits.io'
    assert_not user.save
  end

  test 'should not save invalid email' do
    user = User.new first_name: 'John', last_name: 'Smith', email: 'john@example'
    assert_not user.save
  end

  test 'should not save invalid phone' do
    user = User.new first_name: 'John', last_name: 'Smith', email: 'john@example.com', phone: '(707) 555-123'
    assert_not user.save
  end

  test 'should not save invalid password' do
    user = User.new first_name: 'John', last_name: 'Smith', email: 'john@example.com', password: '123456'
    assert_not user.save
  end

  # Scopes

  test 'mailable should include users with receive_email = true' do
    assert_equal 1, User.mailable.count
  end

  test 'textable should include users with receive_email = true' do
    assert_equal 1, User.textable.count
  end

  test 'staff should include users with staff role' do
    assert_equal 1, User.staff.count
  end

  test 'admin should include users with admin role' do
    assert_equal 2, User.admins.count
  end

  # Methods

  test 'to_s should return full name' do
    assert_equal 'Dylan Waits', users(:dylan).to_s
  end

  test 'normalize_phone should strip all non-numeric characters' do
    user = User.create first_name: 'John', last_name: 'Smith', email: 'john@example.com', phone: '(707) 555-1234'
    assert_equal '7075551234', user.phone
  end

  test 'authenticate should return true on valid password' do
    assert @dylan.authenticate('testing123')
    assert_equal 0, @dylan.failed_attempts
    assert_nil @dylan.locked_at
  end

  test 'authenticate should increment failed_attempts' do
    assert_not @dylan.authenticate('fakepass')
    assert_equal 1, @dylan.failed_attempts
    assert_not_nil @dylan.locked_at
  end

  test 'locked_until should return locked_at plus delay' do
    @dylan.locked_at = DateTime.now
    @dylan.failed_attempts = 5
    assert_equal 60, @dylan.locked_until - @dylan.locked_at
    @dylan.failed_attempts = 9
    assert_equal 960, @dylan.locked_until - @dylan.locked_at
  end

  test 'locked? should return true' do
    @dylan.locked_at = DateTime.now
    @dylan.failed_attempts = 5
    assert @dylan.locked?
  end

  test 'should set password_updated_at when changing password' do
    old_value = @dylan.password_updated_at
    @dylan.password = 'newpassword123'
    @dylan.save!
    assert_not_equal old_value, @dylan.password_updated_at
    assert_in_delta DateTime.now.to_i, @dylan.password_updated_at.to_i, 1
  end

end
