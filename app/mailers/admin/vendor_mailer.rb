class Admin::VendorMailer < ApplicationMailer
  default from: 'Wedding Expo <info@weddingexpo.co>'

  # Sent to vendors when their booth details are updated.
  def booth_updated(booth)
    to = booth.vendor.users.pluck(:email)
    subject = "Your Booth has been Updated"
    changes = booth.previous_changes
      .select { |k, v| k =~ /status|size|total|balance|payment_method|payment_schedule|industries/ }
      .map { |c| "  - #{c[0].humanize} changed from #{c[1][0]} to #{c[1][1]}"}.join("\n")
    body = <<EOS
Your booth in the #{booth.show.date.to_s(:semiformal)} Wedding Expo has been updated. The
following changes were made:

#{changes}
EOS
    mail(to: to, subject: subject, body: body, content_type: 'text/plain')
  end

  # Sent to vendors when a scheduled payment or subscription is declined.
  def declined_payment(payment)
    subject = "Payment Error"
    vendor = payment.payer
    card = payment.card
    amount = "$#{payment.amount / 100.0}".sub(/\.0$/, ".00")
    body = <<-EOS
      #{vendor},

      We tried to run your credit card for a payment of #{amount} but it seems there was an issue with the card on file.
      Please log in to your account and review your card and make any changes necessary. It is possible you may need to
      contact your bank to approve the payment.

      If you have any questions, don't hesitate to call or email.

      The Wedding Expo
      (707) 544-3695 ext. 3
      info@weddingexpo.co
    EOS

    mail(to: vendor.email, subject: subject, body: body, content_type: 'text/plain')
  end

  # Sent to vendors who have a payment scheduled in 7 days.
  def upcoming_payment(payment)
    subject = "Upcoming Payment Reminder"
    vendor = payment.payer
    booth = payment.payable
    amount = "$#{payment.amount / 100.0}".sub(/\.0$/, ".00")
    return unless vendor && booth
    body = <<-EOS
      #{vendor},

      This is a reminder that you have a payment of #{amount} for
      the #{booth.show} Wedding Expo scheduled to be charged
      in seven days. Please contact us if you have any questions.

      The Wedding Expo
      (707) 544-3695 ext. 3
      info@weddingexpo.co
    EOS

    mail(to: vendor.email, subject: subject, body: body, content_type: 'text/plain')
  end
end
