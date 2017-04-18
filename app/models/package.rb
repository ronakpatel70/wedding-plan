class Package < ActiveRecord::Base
  enum type: [:grand, :highlighted, :standard]

  has_and_belongs_to_many :prizes
  belongs_to :show, required: true
  belongs_to :winner, class_name: 'User'

  validates_length_of :name, in: (0..40), allow_nil: true
  validate :winner_is_eligible, if: :winner_id_changed?

  strip_attributes collapse_spaces: true

  self.inheritance_column = nil

  def to_s
    name || ''
  end

  def value
    prizes.sum(:value)
  end

  private
    def winner_is_eligible
      return unless winner

      unless winner.shows.exists?(id: show_id)
        errors.add(:winner, "has not registered at this show")
      end

      if standard? && Package.exists?(winner: winner, show: show, type: :standard)
        errors.add(:winner, "has already redeemed a prize at this show")
      end
    end
end
