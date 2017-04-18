class Event < ActiveRecord::Base
  has_many :points
  has_and_belongs_to_many :users

  scope :future, -> {where("date > ? OR (date IS NULL AND events.created_at > ?)", Date.today, Date.today - 18.months)}
  scope :past, -> {where("date <= ? OR (date IS NULL AND events.created_at <= ?)", Date.today, Date.today - 18.months)}
  scope :tbd, -> {where("date IS NULL")}
  scope :rewards, -> {where("joined_rewards_at IS NOT NULL")}

  def to_s(format = :semiformal)
    if self.date
      self.date.to_s format
    else
      'TBD'
    end
  end

  def rewards?
    joined_rewards_at != nil
  end

  def rewards_deadline
    if date
      date - 45
    else
      nil
    end
  end

  def rewards_points_needed
    case rewards_tier
      when 1 then 5
      when 2 then 10
      when 3 then rewards_points
    end - rewards_points
  end

  def rewards_tier
    case rewards_points
      when 0..4 then 1
      when 5..9 then 2
      when 10..99 then 3
    end
  end
end
