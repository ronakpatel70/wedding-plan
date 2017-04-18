class Transfer < ActiveRecord::Base
  enum status: [:pending, :in_transit, :paid, :canceled, :failed]

  belongs_to :user, required: true

  validates_numericality_of :amount, greater_than_or_equal_to: 100, message: 'must be at least $1.00'
  validates_presence_of :description, :stripe_recipient_id

  before_validation :set_stripe_recipient_id
  before_create :process

  private
    def set_stripe_recipient_id
      self.stripe_recipient_id = user&.stripe_recipient_id
    end

    def process
      begin
        transfer = Stripe::Transfer.create(
          :amount => amount,
          :currency => "usd",
          :recipient => stripe_recipient_id,
          :description => "#{description} for #{user}",
          :statement_descriptor => "WEDDING EXPO PAYCHECK"
        )
        self.stripe_transfer_id = transfer[:id]
      rescue Stripe::InvalidRequestError => e
        errors.add "Stripe:", e.message
        return false
      end
    end
end
