class Booth < ActiveRecord::Base
  enum payment_method: [:card, :check, :cash, :trade]
  enum payment_schedule: [:full, :deposit, :monthly]
  enum status: [:pending, :approved, :denied]

  belongs_to :show, required: true
  belongs_to :vendor, required: true
  belongs_to :card
  belongs_to :coordinate, dependent: :destroy
  has_many :add_ons, dependent: :delete_all
  has_many :fees, dependent: :delete_all
  has_many :payments, as: :payable
  belongs_to :sign

  accepts_nested_attributes_for :add_ons, allow_destroy: true
  accepts_nested_attributes_for :coordinate

  validates_associated :add_ons
  validates_presence_of :payment_method
  validates_presence_of :payment_schedule
  validates_inclusion_of :size, in: Config.booths.keys, allow_nil: true
  validates_numericality_of :free_pass_limit, greater_than: 0
  validates_uniqueness_of :sign_id, scope: :show_id, allow_nil: true
  validate :add_ons_are_valid

  before_create :mark_vendor_as_sold
  before_save :calculate_total
  before_save :attach_sign, if: :status_changed?
  after_update :send_welcome_text, if: :checked_in_at_changed?
  before_destroy :nullify_payments
  after_destroy :destroy_coordinate
  strip_attributes only: [:size]

  scope :flagged, -> {where(flagged: true)}
  scope :visible, -> {where(visible: true)}
  scope :with_add_on, ->(add_on_type) {joins(:add_ons).where("add_ons.type = ?", add_on_type)}
  scope :with_balance, -> {where("balance > 0")}
  scope :with_bag, -> {joins(:add_ons).where("add_ons.type = 'bag_promo'")}
  scope :with_industries, -> {where("ARRAY_LENGTH(industries, 1) > 0")}
  scope :with_sign, -> {joins(:add_ons).where("add_ons.type = 'sign'")}
  scope :with_size, -> {where.not(size: nil)}
  scope :without_size, -> {where(size: nil)}

  def to_s
    (size ? "#{size} Booth" : (bag_promo? ? "Bag Promo"  : "Empty Application")) + " - " + show.date.to_s(:mth_yr)
  end

  def bag_promo?
    add_ons.where(type: 'bag_promo').count > 0
  end
  alias :bag? :bag_promo? # bag? is deprecated, use bag_promo?

  def editable?
    if self.new_record?
      true
    else
      Date.today < show.payment_deadline
    end
  end

  # Recalculates the total due based on the booth size and add-ons.
  def calculate_total
    sub_total = 0

    if size
      sub_total += Config.booths[size][:price]
    end

    self.add_ons.each do |add_on|
      sub_total += add_on.total
    end
    sub_total += industries.length * 35000
    sub_total += fees.pluck(:amount).reduce(0, &:+)

    self.total = sub_total
    self.balance = total - payments.paid.map(&:amount_paid).reduce(0, &:+)
    self
  end

  def door
    coordinate && Config.sections[coordinate.section]
  end

  def has_add_on?(type, value=nil)
    a = add_ons.where(type: type)
    a = a.where(value: value) if value
    a.count > 0
  end

  def line_items
    items = []

    if size && details = Config.booths[size]
      items << {type: "booth", title: details[:name] + " Booth", price: details[:price]}
    end

    add_ons.each do |add_on|
      add_on && add_on.price > 0 && items << { type: "add_on", title: add_on.to_s,
        price: add_on.price, quantity: add_on.quantity }
    end
    industries.each { |ind| items << { type: "industry", title: "Extra Industry (#{ind.titleize})", price: 35000 } }
    fees.each { |fee| items << { type: "fee", title: fee.description, price: fee.amount, id: fee.id } }

    items
  end

  def payment_deadline
    if created_at > show.date - 30.days
      created_at.to_date
    elsif card?
      show.date - 30.days
    else
      created_at.to_date + 30.days
    end
  end

  private
    def attach_sign
      self.sign = approved? && has_add_on?("sign") ? vendor.signs.unused(show_id).order("back DESC, id DESC").limit(1).first : nil
    end

    def destroy_coordinate
      coordinate && coordinate.delete
    end

    def nullify_payments
      payments.scheduled.delete_all
      payments.update_all(payable_id: nil, payable_type: nil)
    end

    def add_ons_are_valid
      industries&.reject!(&:blank?)

      if industries.include?(vendor&.industry)
        errors.add(:industries, "can't include vendor's default industry")
      elsif industries.include?("photography")
        errors.add(:industries, "can't include photography")
      end
    end

    def mark_vendor_as_sold
      statuses = vendor.show_statuses.merge(show_id.to_s => "sold")
      vendor.update_column("show_statuses", statuses)
    end

    def send_welcome_text
      return unless vendor.cell_phone
      Text.create(recipient: vendor, message: "Hello! Thanks for being part of The Wedding Expo. Use this text number for any questions or concerns you have, it's the quickest way for us to help you.")
    end
end
