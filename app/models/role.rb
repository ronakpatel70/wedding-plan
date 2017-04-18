class Role < ActiveRecord::Base
  enum type: [:admin, :staff]

  belongs_to :user, required: true

  validates_uniqueness_of :type, scope: :user

  self.inheritance_column = nil

  def to_s
    type.titleize
  end
end
