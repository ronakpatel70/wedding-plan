class Article < ActiveRecord::Base
  enum page: [:vendor_handbook, :staff_handbook, :terms, :vendor_terms, :rewards_terms, :rewards_vendor_terms]

  validates_length_of :title, in: 1..50
  validates_uniqueness_of :order, scope: :page

  strip_attributes only: :title, collapse_spaces: true

  default_scope {order(:page, :order)}

  def to_s
    title
  end
end
