require 'active_support/concern'

module StripeRecipient
  extend ActiveSupport::Concern

  included do
    attr_accessor :full_name, :stripe_recipient_token, :tax_id
    belongs_to :default_card, class_name: 'Card'
    before_update :create_stripe_recipient, if: :stripe_recipient_token
    before_update :update_stripe_recipient,
      if: -> { email_changed? || first_name_changed? || last_name_changed? }

    protected
      def create_stripe_recipient
        begin
          recipient = Stripe::Recipient.create(
            name: full_name,
            type: "individual",
            description: self.to_s,
            email: email,
            tax_id: tax_id
          )
          self.stripe_recipient_id = recipient.id
        rescue Stripe::InvalidRequestError => e
          errors.add(:base, e.message.chop)
          throw(:abort)
        end
      end

      def update_stripe_recipient
        return unless self.stripe_recipient_id

        begin
          cu = Stripe::Recipient.retrieve(self.stripe_recipient_id)
          cu.email = email
          cu.description = self.to_s
          cu.save
        rescue Stripe::InvalidRequestError => e
          errors.add(:base, e.message.chop)
          throw(:abort)
        end
      end
  end
end
