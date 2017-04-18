class Prize < ActiveRecord::Base
  enum type: [:grand, :highlighted, :standalone, :discount]
  enum status: [:pending, :approved, :denied]

  belongs_to :coordinate
  has_and_belongs_to_many :packages
  belongs_to :show, required: true
  belongs_to :vendor, required: true

  validates_length_of :name, in: (0..40), message: "must be 40 characters or less"
  validates_inclusion_of :quantity, in: (1..50), message: "must be between 1 and 50"
  validates_numericality_of :value, greater_than_or_equal_to: 1000, message: "must be 10 or more"

  strip_attributes collapse_spaces: true

  self.inheritance_column = nil

  def to_s
    name
  end

  def full_name
    name =~ /\$[0-9]+/ ? name : "#{name} ($#{value/100})"
  end
end
