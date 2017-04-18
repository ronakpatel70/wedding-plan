class Text < ActiveRecord::Base
  enum group: [:all_booths, :highlighted]
  enum status: [:sent, :failed, :read, :unread]

  belongs_to :sender, polymorphic: true, required: false
  belongs_to :recipient, polymorphic: true, required: false

  validates_presence_of :message
  validates_length_of :message, maximum: 160

  before_create :dispatch

  private
    def dispatch
      if sender_id == nil && recipient_id == nil && group
        # Send SMS to all booths in the current show
        vendors = if all_booths?
          Show.current.booths.approved.where.not(size: nil)
        elsif highlighted?
          Show.current.prizes.approved.highlighted
        end
        vendors = vendors.map { |x| x.vendor }.reject { |v| v.cell_phone.blank? }

        vendors.each_slice(15) do |slice|
          Thread.new do
            slice.each { |v| Dispatch.sms(v.cell_phone, message) }
          end
        end

        self.sender_tel = '7078760001'
        self.recipient_tel = "#{vendors.length} recipients"
      elsif recipient_type == 'Vendor'
        # Send SMS to a single vendor
        errors.add(:recipient, 'must have a valid cell phone')
        throw(:abort) unless recipient.cell_phone
        Dispatch.sms(recipient.cell_phone, message)
        self.sender_tel = '7078760001'
        self.recipient_tel = recipient.cell_phone
      end
    end
end
