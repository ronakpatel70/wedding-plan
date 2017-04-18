class Fee < ActiveRecord::Base
  belongs_to :booth, required: true

  validates_numericality_of :amount, other_than: 0
  validates_presence_of :description

  after_create -> { booth.save! }
  after_destroy -> { booth.save! }
  strip_attributes only: :description, collapse_spaces: true
end
