require 'active_support/concern'

module StripeCustomer
  extend ActiveSupport::Concern

  included do
    belongs_to :default_card, class_name: 'Card'
    before_update :update_stripe_customer,
      if: -> { email_changed? || default_card_id_changed? }

    protected
      def update_stripe_customer
        return unless self.stripe_customer_id

        begin
          cu = Stripe::Customer.retrieve(self.stripe_customer_id)
          cu.default_source = self.default_card&.stripe_card_id
          cu.email = self.email
          cu.description = self.to_s
          cu.save
        rescue Stripe::InvalidRequestError => e
          errors.add(:base, e.message.chop)
          throw(:abort)
        end
      end
  end
end
