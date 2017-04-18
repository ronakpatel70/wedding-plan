class Card < ActiveRecord::Base
  enum status: [:active, :declined, :disputed, :canceled, :deleted]

  has_many :payments, dependent: :nullify
  belongs_to :owner, polymorphic: true, required: true

  before_destroy :clear_owner_default_card
  before_update :clear_owner_default_card, if: :status_changed?

  def self.create_with_token(token, owner)
    raise("owner is required") unless owner

    if cid = owner.stripe_customer_id
      customer = Stripe::Customer.retrieve(cid)
    else
      customer = Stripe::Customer.create(:description => owner.to_s, :email => owner.email)
      owner.update_column "stripe_customer_id", customer.id
    end

    begin
      response = customer.sources.create(:card => token)
      card = Card.create(owner: owner, stripe_card_id: response.id,
        name: owner.to_s, expiry: Date.new(response.exp_year, response.exp_month),
        brand: response.brand, funding: response.funding, last4: response.last4)
      owner.update :default_card => card
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      card = Card.new(owner: owner)
      card.errors.add(:base, e.message.chop)
    end

    card
  end

  def to_s
    brand.sub("American Express", "Amex") + " " + last4
  end

  private
    def clear_owner_default_card
      if owner&.default_card == self
        owner.update_column('default_card_id', nil)
      end
    end
end
