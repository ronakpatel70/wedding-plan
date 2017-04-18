require 'test_helper'

class CardTest < ActiveSupport::TestCase

  setup do
    stub_request(:post, "https://api.stripe.com/v1/tokens").to_return(:body => File.open("test/stubs/token.json"))
    stub_request(:any, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c").to_return(:body => File.open("test/stubs/customer.json"))
    stub_request(:post, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources").to_return(:body => File.open("test/stubs/card.json"))
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources/card_16vGqV2RDM5ZUbA00snzKzqd").to_return(:body => File.open("test/stubs/card.json"))
    stub_request(:delete, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources/card_16vGqV2RDM5ZUbA00snzKzqd").to_return(:body => '{"deleted": true, "id": "card_16vGqV2RDM5ZUbA00snzKzqd"}')
  end

  def generate_token
    Stripe::Token.create(
      :card => {
        :name => "Test Card",
        :number => "4242424242424242",
        :exp_month => 10,
        :exp_year => 2016,
        :cvc => "314"
      }
    )
  end

  # Validations

  test "should not save without owner" do
    assert_raise(RuntimeError) do
      card = Card.create_with_token generate_token, nil
    end
  end

  # Class Methods

  test "should create card with token" do
    card = Card.create_with_token generate_token, users(:dylan)
    assert card.is_a? Card
    assert card.persisted?
    assert users(:dylan).default_card == card
  end

  # Methods

  test "to_s" do
    assert_equal "Visa 1111", cards(:one).to_s
    assert_equal "Amex 4000", cards(:two).to_s
  end

  test "should delete card" do
    card = Card.create_with_token generate_token, users(:dylan)
    card.deleted!
    assert card.deleted?
    assert users(:dylan).default_card == nil
  end

end
