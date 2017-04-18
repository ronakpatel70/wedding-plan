class Ticket < ActiveRecord::Base
  attr_accessor :payment_method

  belongs_to :show, required: true
  belongs_to :user, required: true
  belongs_to :vendor
  has_one :payment, as: :payable

  validates_numericality_of :quantity, greater_than: 0, less_than: 100
  validates_presence_of :payment_method, on: :create, unless: :free

  before_create :create_payment

  scope :free, -> {where(free: true)}
  scope :not_free, -> {where(free: false)}
  scope :paid, -> {where(free: false, paid: true)}

  def destroy
    if paid and !free
      payment.update refund_amount: payment.amount
      update_column 'paid', false
    else
      delete
    end
  end

  private
    def create_payment
      unless free
        self.payment = Payment.new method: payment_method, amount: quantity * show.current_ticket_price,
          description: ActionController::Base.helpers.pluralize(quantity, 'Wedding Expo ticket'), payer: user
        payment.card = user.default_card if payment_method.to_s == 'card'
        unless payment.save
          errors.add(:payment_method, 'is not valid')
          throw(:abort)
        end
      end
    end
end
