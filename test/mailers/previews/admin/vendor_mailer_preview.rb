# Preview all emails at http://localhost:3000/rails/mailers/admin/vendor_mailer

class Admin::VendorMailerPreview < ActionMailer::Preview
  def booth_updated_preview
    booth = Booth.find(990)
    booth.update(size: '6x6')
    booth.update(size: '6x20')
    Admin::VendorMailer.booth_updated(booth)
  end

  def declined_payment_preview
    payment = Payment.card.declined.first
    Admin::VendorMailer.declined_payment(payment)
  end

  def upcoming_payment_preview
    payment = Payment.card.scheduled.first
    Admin::VendorMailer.upcoming_payment(payment)
  end
end
