class Subscription < ActiveRecord::Base
  enum status: [:trialing, :active, :past_due, :canceled, :unpaid]

  belongs_to :vendor, required: true
  has_many :payments, as: :payable

  validates_presence_of :plan
  validates_presence_of :stripe_customer_id, message: "is not set on vendor"
  validate :is_unique, on: :create

  before_validation :set_stripe_customer_id, on: :create
  before_create :process
  before_update :update_plan, if: lambda { |sub| sub.plan_changed? || sub.coupon_changed? }
  strip_attributes

  # Deletes the Stripe subscription and changes the status to "canceled".
  def destroy
    customer = Stripe::Customer.retrieve(stripe_customer_id)
    customer.subscriptions.retrieve(stripe_subscription_id).delete
    self.update(status: "canceled", canceled_at: Time.now)
  end

  # Pays the current invoice immediately. Returns true if successful.
  def pay
    return false unless past_due? || unpaid?

    customer = Stripe::Customer.retrieve(stripe_customer_id)
    invoice = customer.invoices(closed: false).data.first
    return false unless invoice

    begin
      invoice.pay
      return invoice["closed"]
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      return false
    end
  end

  private
    def is_unique
      if Subscription.find_by(vendor_id: vendor_id, plan: plan, status: [0, 1, 2, 4])
        errors.add(:vendor, "already has a subscription to this plan")
      end
    end

    def set_stripe_customer_id
      self.stripe_customer_id = vendor&.stripe_customer_id
    end

    def process
      begin
        customer = Stripe::Customer.retrieve(stripe_customer_id)
        subscription = customer.subscriptions.create(plan: self.plan, coupon: self.coupon, trial_end: self.trial_end&.to_i)
        self.stripe_subscription_id = subscription["id"]
        self.status = subscription["status"]
        self.current_period_end = Time.at(subscription["current_period_end"])
      rescue Stripe::CardError, Stripe::InvalidRequestError => e
        errors.add(:base, e.message.chop)
        throw(:abort)
      end
    end

    def update_plan
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      subscription = customer.subscriptions.retrieve(stripe_subscription_id)
      if coupon
        subscription.coupon = coupon
      else
        subscription.delete_discount()
      end
      subscription.plan = plan
      subscription.save
    end
end
