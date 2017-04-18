class JobApplication < ActiveRecord::Base
  enum status: [:pending, :approved, :denied, :unavailable]
  belongs_to :user, required: true
  belongs_to :show, required: true

  validates_uniqueness_of :user_id, scope: :show_id

  strip_attributes collapse_spaces: true
end
