require 'test_helper'

class TextTest < ActiveSupport::TestCase
  test "should save valid text" do
    stub_request(:post, SMS_URL).to_return(:body => File.open("test/stubs/sms.json"))
    text = Text.new(recipient: vendors(:one), message: "Hi")

    assert text.save
    assert text.sent?
  end

  test "should not save long message" do
    text = Text.new(recipient: vendors(:one), message: "This is a really long message" * 10)

    assert_not text.save
  end

  test "should not save without recipient phone" do
    text = Text.new(recipient: vendors(:two), message: "Hi")

    assert_not text.save
  end
end
