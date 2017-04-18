class Location < ActiveRecord::Base
  belongs_to :address, required: true
  has_many :shows

  accepts_nested_attributes_for :address

  validates_presence_of :name
  validates_format_of :handle, with: /\A([a-z]+-)*[a-z]+\Z/, message: 'is invalid'
  validates_uniqueness_of :handle, message: 'is already in use'

  before_destroy :destroy_associations
  strip_attributes collapse_spaces: true

  def to_s
    name
  end

  private
    def destroy_associations
      shows.destroy_all
    end
end
