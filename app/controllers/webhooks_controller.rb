class WebhooksController < ActionController::Base
  def stripe
    return head :bad_request unless params[:data]&.has_key?(:object)
    obj = params[:data][:object]

    case params[:type]
    when "charge.succeeded"
      return head(:no_content) if Payment.find_by(stripe_charge_id: obj[:id])
      return head(:bad_request) unless vendor = Vendor.find_by(stripe_customer_id: obj[:customer])
      return head(:bad_request) unless card = Card.find_by(stripe_card_id: obj[:source][:id])

      desc = obj[:description] || obj[:statement_descriptor] || "[Automatic payment]"
      time = Time.at(obj[:created].to_i)
      payment = Payment.new(payer: vendor, card: card, stripe_charge_id: obj[:id],
        amount: obj[:amount].to_i, description: desc, captured_at: time)

      if payment.save(validate: false)
        head :no_content
      else
        render text: "Failed to save payment.", status: 500
      end
    when "customer.subscription.updated"
      return head(:bad_request) unless sub = Subscription.find_by(stripe_subscription_id: obj[:id])

      sub.current_period_end = Time.at(obj[:current_period_end].to_i)
      sub.status = obj[:status]

      if sub.save(validate: false)
        head :no_content
      else
        render text: "Failed to update subscription.", status: 500
      end
    when "customer.source.updated"
      return head(:bad_request) unless card = Card.find_by(stripe_card_id: obj[:id])

      card.last4 = obj[:last4]
      card.expiry = Date.new(obj[:exp_year].to_i, obj[:exp_month].to_i)
      if card.save(validate: false)
        head :no_content
      else
        render text: "Failed to update card.", status: 500
      end
    else
      # Return 400 on unknown event type
      head :bad_request
    end
  end

  def twilio
    from = params['From'].sub('+1', '')
    to = params['To'].sub('+1', '')
    sender = Vendor.find_by(cell_phone: from)
    text = Text.create(sender: sender, sender_tel: from, recipient_tel: to, message: params['Body'], status: :unread)
    head :ok
  end
end
