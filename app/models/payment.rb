class Payment < ActiveRecord::Base
  enum method: [:card, :check, :cash, :trade, :credit]
  enum status: [:paid, :refunded, :declined, :disputed, :lost, :won, :scheduled]

  belongs_to :card
  belongs_to :payer, polymorphic: true, required: true
  belongs_to :payable, polymorphic: true

  validates_numericality_of :amount, greater_than_or_equal_to: 100
  validates_presence_of :description
  validate :method_and_card_match, on: :create
  validate :refund_amount_is_positive
  validate :scheduled_for_is_future, if: :scheduled_for?, on: :create
  validate :scheduled_for_includes_card, if: :scheduled_for?, on: :create

  before_create :process, if: :card?
  before_create -> { self.captured_at = Time.now }, unless: :card?
  after_create -> { payable&.save! }, if: :paid?
  before_update :refund, if: :refund_amount_changed?
  after_destroy -> { payable&.save! }, if: :paid?

  def charge_now!(options = {})
    return false if stripe_charge_id != nil
    begin
      charge = Stripe::Charge.create(
        :capture => true,
        :amount => amount,
        :currency => 'usd',
        :customer => card.owner.stripe_customer_id,
        :source => card.stripe_card_id,
        :description => description
      )
      self.stripe_charge_id = charge.id
      self.status = :paid
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      self.stripe_charge_id = e.json_body[:error][:charge]
      self.status = :declined
      self.reason = e.message
      errors.add(:base, e.message.chop)
    end

    self.captured_at = Time.now
    self.scheduled_for = nil
    save(validate: false) and payable&.save! if options[:save]
  end

  # Returns the net amount that has been collected from the payer.
  def amount_paid
    (amount - refund_amount if paid? || won?).to_i
  end

  def refundable?
    !new_record? && refund_amount < amount && %q(paid refunded won).include?(status)
  end

  private
    # Callbacks
    def process
      if scheduled_for
        self.status = :scheduled
        return
      elsif stripe_charge_id != nil
        return
      elsif card
        charge_now!
      else
        errors.add('Card', 'is required for this payment method')
        throw(:abort)
      end
    end

    def refund
      self.status = :refunded if refund_amount == amount
      if method == 'card'
        Stripe::Refund.create(charge: stripe_charge_id, amount: refund_amount)
      end
      payable.increment!(:balance, refund_amount - refund_amount_was) if payable&.respond_to?(:balance)
    end

    # Validations
    def method_and_card_match
      if method != 'card' && card_id != nil
        errors.add(:method, 'must be card if a card is selected')
      end
    end

    def refund_amount_is_positive
      return unless amount
      if refund_amount < refund_amount_was
        errors.add(:refund_amount, 'can\'t be lower than previous value')
      elsif refund_amount > amount
        errors.add(:refund_amount, 'is greater than amount paid')
      end
    end

    def scheduled_for_is_future
      errors.add(:scheduled_for, 'must be in the future') if scheduled_for <= Date.today
    end

    def scheduled_for_includes_card
      errors.add(:card, 'is required to schedule payment') if method != 'card' || card_id == nil
    end
end
