def tablef(payments, lastcol = "STATUS", lastval = "status")
  table = " ID    | PAYER                | AMOUNT   | #{lastcol}     \n"
  table += "------------------------------------------------------\n"
  payments.each do |payment|
    if payment.is_a? Subscription
      table += sprintf(" %-5s   %-20s   %-10s\n", payment.id, payment.vendor.to_s[0,20], "#{payment.plan}")
    else
      table += sprintf(" %-5s   %-20s   %-10s %-7s\n", payment.id, payment.payer.to_s[0,20], "$#{payment.amount / 100.0}", payment.send(lastval))
    end
  end
  return table
end

namespace :payments do
  task :run => :environment do
    # Run payments that are scheduled for today or earlier
    payments = Payment.card.scheduled.where("scheduled_for <= ?", Date.today).where.not(card_id: nil)
    payments.each do |payment|
      payment.charge_now!(save: true) unless ENV['DRY']
      Admin::VendorMailer.declined_payment(payment) if payment.declined?
    end

    # Notify vendors of payments scheduled for 7 days out
    payments_next_week = Payment.scheduled.where(scheduled_for: Date.today + 7.days)
    payments_next_week.each do |payment|
      puts "Emailing #{payment.payer&.email} about payment ##{payment.id}"
      Admin::VendorMailer.upcoming_payment(payment).deliver_now unless ENV['DRY']
    end

    digest = "\nPayments run today:\n" + tablef(payments)
    upcoming_payments = Payment.card.scheduled.where(scheduled_for: (Date.today..Date.today+7.days)).where.not(card_id: nil)
    digest += "\nPayments scheduled to run in the next week:\n" + tablef(upcoming_payments, "ON", :scheduled_for) + "\n"
    subscriptions = Subscription.active.where(current_period_end: (Date.today.beginning_of_day..Date.today.end_of_day))
    digest += "\nSubscriptions renewing today:\n" + tablef(subscriptions, nil, nil) + "\n"

    to = Config.notifications['billing']
    AdminMailer.notify(to, 'Scheduled Payment Digest', digest).deliver_now unless ENV['DRY']
    puts digest
  end
end
