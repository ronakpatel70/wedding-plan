class Position < ActiveRecord::Base
  has_many :shifts, dependent: :destroy

  validates_length_of :name, in: (1..40)
  validates_length_of :short_description, in: (1..100)
  validates_numericality_of :quantity, greater_than: 0
  validates_presence_of :default_start, :default_end

  strip_attributes except: [:description], collapse_spaces: true

  scope :active, -> {where(active: true)}
  scope :inactive, -> {where(active: false)}

  def to_s
    name
  end

  def relative_start(time)
    Time.parse(default_start).change(year: time.year, month: time.month, day: time.day)  - (12 - time.hour).hours
  end

  def relative_end(time)
    Time.parse(default_end).change(year: time.year, month: time.month, day: time.day)  - (12 - time.hour).hours
  end
end
