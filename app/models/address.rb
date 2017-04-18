class Address < ActiveRecord::Base
  validates_presence_of :street, :city
  validates_format_of :state, with: /\A[a-z]{2}\Z/i, message: 'must be 2 characters'
  validates_format_of :zip, with: /\A[0-9]{5}\Z/, message: 'must be 5 digits'

  strip_attributes collapse_spaces: true

  def to_s
    "#{street}\n#{city}, #{state} #{zip}"
  end

  def city_state_zip
    "#{city}, #{state} #{zip}"
  end
end
