class Message < ActiveRecord::Base
  enum type: [:email, :sms]

  belongs_to :sender, polymorphic: true, required: true
  belongs_to :recipient, polymorphic: true, required: true

  validates_length_of :subject, maximum: 78
  validates_length_of :body, maximum: 1000
  validates_format_of :template, with: /\A[a-z]+(?:_[a-z]+)*\Z/

  before_create :dispatch
  strip_attributes only: [:from, :to, :subject], collapse_spaces: true, replace_newlines: true

  self.inheritance_column = nil

  def to_s
    "Message ##{id}"
  end

  private
    def dispatch
      if email?
        self.from = sender.email
        self.to = recipient.email
        if Messenger.respond_to?(template)
          Messenger.send(template, sender, recipient, subject, body).deliver_now
        else
          Messenger.generic_message(sender, recipient, subject, body).deliver_now
        end
      elsif sms?
        self.from = sender.sms
        self.to = sender.sms
        # Send sms
      end
    end
end
