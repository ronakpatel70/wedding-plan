class Dispatch
  attr_accessor :method
  attr_accessor :subject
  attr_accessor :message
  attr_accessor :token

  def initialize(recipient, message, subject = nil, method = nil)
    if method
      self.method = method
    else
      self.method = if recipient.receive_sms then :sms else :sms end
    end
    self.subject = subject
    self.message = message
    if recipient.is_a? String
      self.token = recipient
    else
      self.token = case self.method
        when :mail then recipient.email
        when :sms then recipient.phone
        when :push then receipient.push_token
        else nil
      end
    end

    if self.method == :sms and self.token !~ /\+?1?[0-9]{10}/
      raise 'Invalid SMS Number'
    end
  end

  def self.mail(recipient, message, subject)
    self.new(recipient, message, subject, :mail).deliver!
  end

  def self.sms(recipient, message)
    self.new(recipient, message, nil, :sms).deliver!
  end

  def deliver!
    case method
      when :mail then deliver_mail
      when :sms then deliver_sms
      when :push then deliver_push
      else false
    end
  end

  private
    def deliver_mail
      Mailer.generic(token, subject, message).deliver
    end

    def deliver_sms
      message.gsub! /https?:\/\/(?:[a-z0-9-]+\.)+[a-z]{2,}(?:\/(?:[a-zA-Z0-9_-]+(?:\.[a-z]+)?)?)*\??(?:[a-z0-9_]+(?:=[a-z0-9_]*)?&?)*/i do |url|
        HTTP.post('http://wcb.io', json: {url: url, expires: 172800}).headers['Location']
      end

      raise 'SMS messages must be 160 characters or less' if message.length > 160
      raise 'Unicode SMS messages must be 140 characters or less' if message !~ /^[ -~\t\n\r]+$/ and message.length > 140

      account_sid = Rails.application.secrets.twilio_account_sid
      auth_token = Rails.application.secrets.twilio_auth_token

      @client = Twilio::REST::Client.new account_sid, auth_token
      @response = @client.account.messages.create({
        :from => (Rails.env.production? ? '+17078760001' : '+15005550006'),
        :to => (Rails.env.production? ? token : '+17075272685'),
        :body => message
      })
    end

    def deliver_push

    end
end
