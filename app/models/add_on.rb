class AddOn < ActiveRecord::Base
  belongs_to :booth, required: true

  validates_inclusion_of :type, in: Config.add_ons.keys
  validates_numericality_of :price, greater_than_or_equal_to: 0
  validates_numericality_of :quantity, greater_than: 0

  before_create :set_default_price
  before_create :set_default_value
  after_create :update_booth_total, if: -> {price > 0}
  after_destroy :update_booth_total, if: -> {price > 0}
  strip_attributes only: :description, collapse_spaces: true

  self.inheritance_column = nil

  def self.generate(*types)
    types.map { |t| self.new(type: t) }
  end

  def to_s
    str = if quantity == 1 then config[:name] else "#{quantity} #{config[:name].pluralize}" end
    str += " (#{value})" if value
    str
  end

  def config
    Config.add_ons[self.type]
  end

  def total
    self.quantity * self.price
  end

  private
    def update_booth_total
      self.booth.reload.calculate_total.save!
    end

    def set_default_price
      if booth.size && config.has_key?(:combo_price)
        self.price = config[:combo_price].to_i
      else
        self.price = config[:price].to_i
      end
    end

    def set_default_value
      default_key = config[:default]
      if default_key && booth.size
        self.value ||= Config.booths[booth.size][default_key]
      end
    end
end
