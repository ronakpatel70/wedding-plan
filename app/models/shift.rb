class Shift < ActiveRecord::Base
  enum status: [:pending, :confirmed, :canceled]

  belongs_to :user, required: true
  belongs_to :position, required: true
  belongs_to :show, required: true

  validates_presence_of :start_time, :end_time

  before_validation :set_default_times, on: :create
  before_update :reset_status

  scope :on, -> (date) {where(start_time: (date.beginning_of_day..date.end_of_day))}

  def duration
    (end_time - start_time).to_i / 60
  end

  def time_worked
    if in_time && out_time
      ((out_time - in_time).to_f / 3600).round(1)
    else
      0
    end
  end

  private
    def reset_status
      if confirmed? && (start_time_changed? || end_time_changed?)
        self.status = :pending
      end
    end

    def set_default_times
      return unless position && show
      self.start_time ||= position.relative_start(show.start)
      self.end_time ||= position.relative_end(show.start)
    end
end
