class Offer < ActiveRecord::Base
  enum type: [:percent, :dollar, :special]

  belongs_to :vendor, required: true

  validates_numericality_of :tier, greater_than: 0, less_than: 4
  validates_numericality_of :value, greater_than: 0
  validates_presence_of :name
  validates_uniqueness_of :tier, scope: :vendor_id

  strip_attributes collapse_spaces: true

  self.inheritance_column = nil

  def to_s
    "Tier #{tier}: #{name}"
  end
end
