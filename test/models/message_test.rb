require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  # Validations

  test "should fail without sender" do
    message = Message.new(recipient: vendors(:one), template: "test", subject: "abcdefgh", body: "Test")
    assert_not message.save
  end

  test "should fail without recipient" do
    message = Message.new(sender: users(:dylan), template: "test", subject: "abcdefgh", body: "Test")
    assert_not message.save
  end

  test "should fail on long subject" do
    message = Message.new(sender: users(:dylan), recipient: vendors(:one), template: "test", subject: "abcdefgh" * 10, body: "Test")
    assert_not message.save
  end

  test "should fail on long body" do
    message = Message.new(sender: users(:dylan), recipient: vendors(:one), template: "test", subject: "abcdefgh", body: "1234567890-" * 150)
    assert_not message.save
  end

  test "should fail on invalid template" do
    message = Message.new(sender: users(:dylan), recipient: vendors(:one), template: "rewards-message", body: "Test")
    assert_not message.save
  end

  # Methods

  test "#to_s should return string with id number" do
    assert_equal "Message ##{messages(:one).id}", messages(:one).to_s
  end

end
