class Point < ActiveRecord::Base
  enum status: [:pending, :confirmed, :denied]

  belongs_to :event
  belongs_to :vendor, required: true
  after_initialize :set_date
  before_save :add_points
  before_destroy :subtract_points

  validates_presence_of :date
  validates_uniqueness_of :event_id, scope: :vendor_id, allow_nil: true

  scope :past, -> {where("date < ?", Date.today - 45.days)}
  scope :future, -> {where("date >= ?", Date.today - 45.days)}

  private
    def add_points
      confirmed? && status_was != 'confirmed' && event_id && event.increment!(:rewards_points, quantity)
      true
    end

    def set_date
      event_id && self.date = event.date
    end

    def subtract_points
      confirmed? && event.decrement!(:rewards_points, quantity)
      true
    end
end
