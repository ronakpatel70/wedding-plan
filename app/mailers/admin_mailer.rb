class AdminMailer < ApplicationMailer
  def notify(to, subject, body)
    mail(to: to, subject: subject, body: body, content_type: 'text/plain')
  end
end
