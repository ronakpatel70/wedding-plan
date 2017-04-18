class Testimonial < ActiveRecord::Base
  belongs_to :vendor, required: true

  validates_presence_of :quote

  strip_attributes collapse_spaces: true
end
