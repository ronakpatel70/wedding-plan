class Show < ActiveRecord::Base
  has_many :booths, dependent: :destroy
  has_many :job_applications, dependent: :destroy
  belongs_to :location, required: true
  has_many :prizes, dependent: :destroy
  has_many :packages, dependent: :destroy
  has_many :shifts, dependent: :destroy
  has_many :tickets, dependent: :restrict_with_error
  has_and_belongs_to_many :users

  before_destroy :destroy_associations

  scope :previous, -> {where("start < ?", Date.today.beginning_of_day).order('start DESC').limit(1)[0]}
  scope :next, -> {where("start >= ?", Date.today.beginning_of_day).order(:start).limit(1)[0]}
  scope :following, -> {where("start >= ?", Date.today.beginning_of_day).order(:start).limit(1).offset(1)[0]}
  scope :current, -> {where("start >= ?", Date.today.beginning_of_day - 45.days).order(:start).limit(1)[0]}
  scope :recent, -> {where(start: (Date.today.beginning_of_day - 45.days)...Date.today.beginning_of_day).order(:start).limit(1)}
  scope :future, -> {where("start >= ?", Date.today.beginning_of_day).order(:start)}
  scope :past, -> {where("start < ?", Date.today.beginning_of_day).order(:start)}
  scope :fresh, -> {where(start: (Date.today.beginning_of_day - 1.year)...(Date.today.beginning_of_day + 1.year)).order('start DESC')}

  def date=(arr)
    self[:start] = if self.start then self.start.change(year: arr[1], month: arr[2], day: arr[3]) else DateTime.new(arr[1], arr[2], arr[3] + 1) end
    self[:end] = if self.end then self.end.change(year: arr[1], month: arr[2], day: arr[3]) else DateTime.new(arr[1], arr[2], arr[3] + 1) end
  end

  def start=(new)
    if new.is_a? Time
      self[:start] = start.change(hour: new.hour, min: new.min, zone: new.zone)
    else
      super new
    end
  end

  def end=(new)
    if new.is_a? Time
      self[:end] = self.end.change(hour: new.hour, min: new.min)
    else
      super new
    end
  end

  def to_s(format = :semiformal)
    date.to_s format
  end

  def date
    start.to_date if start
  end

  def start_time
    start.to_s :us_time if start
  end

  def end_time
    self.end.to_s :us_time if self.end
  end

  def current_ticket_price
    ebed = early_bird_end_date || Date.new(0)
    case Date.today
    when date
      door_price
    when ebed.tomorrow...date
      online_price
    else
      early_bird_price
    end
  end

  def payment_deadline
    date - 30.days
  end

  def next
    Show.where("location_id = ? AND start > ?", location.id, start).order(:start).limit(1)[0]
  end

  def previous
    Show.where("location_id = ? AND start < ?", location.id, start).order("start DESC").limit(1)[0]
  end
end
