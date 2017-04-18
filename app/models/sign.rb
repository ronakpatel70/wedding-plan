class Sign < ActiveRecord::Base
  has_many :booths
  has_and_belongs_to_many :vendors

  validates_presence_of :front
  validates_uniqueness_of :id

  before_destroy :destroy_associations
  strip_attributes collapse_spaces: true

  scope :blank, -> {where(back: nil)}
  scope :join_booths, -> (show_id) {select('signs.*, vendors.id AS in_use_by').joins("
    LEFT JOIN booths ON booths.show_id = #{show_id} AND booths.sign_id = signs.id
    LEFT JOIN vendors ON vendors.id = booths.vendor_id").group("signs.id, vendors.id")}
  scope :join_vendors, -> {select("ARRAY_AGG(CONCAT_WS(',', v.id, v.name) ORDER BY v.name) AS joined_vendors").joins("
    LEFT JOIN signs_vendors ON signs_vendors.sign_id= signs.id
    LEFT JOIN vendors v ON v.id = signs_vendors.vendor_id")}
  scope :unused, -> (show_id) {join_booths(show_id).where('vendors.name IS NULL')}

  def to_s
    "Sign ##{id}"
  end

  def text
    "#{front}#{' | ' + back if back}"
  end

  private
    def destroy_associations
      booths.update_all(sign_id: nil)
    end
end
