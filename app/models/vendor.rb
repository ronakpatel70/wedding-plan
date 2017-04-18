class Vendor < ActiveRecord::Base
  include StripeCustomer

  SHOW_STATUSES = %w(interested not_interested awaiting_application sold excluded)
  enum industry: [:apparel, :cake, :catering, :dj, :rentals, :favors, :financial, :flowers, :gifts, :health, :travel, :invitations, :jewelry, :live_music,
                  :lodging, :officiant, :photobooths, :photography, :planning, :rehearsal, :site, :salon, :specialty, :transportation, :videography, :wine]
  enum rewards_status: [:eligible, :ineligible, :applied, :approved]
  enum grab_card_status: [:awaiting_design, :awaiting_proof, :ready_to_print, :in_print, :in_stock]

  belongs_to :billing_address, class_name: 'Address'
  belongs_to :storefront_address, class_name: 'Address'
  has_many :points, dependent: :destroy
  has_many :booths, dependent: :destroy
  has_many :cards, as: :owner, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :payments, as: :payer, dependent: :restrict_with_error
  has_many :prizes, dependent: :destroy
  has_and_belongs_to_many :signs
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :testimonials, dependent: :destroy
  has_many :tickets, dependent: :nullify
  has_and_belongs_to_many :users
  has_attached_file :profile_image, :styles => { :medium => ["680x480#", :jpg], :thumb => ["170x120#", :jpg], :tiny => ["88x88#", :jpg] }, :default_style => :medium

  accepts_nested_attributes_for :billing_address, :storefront_address, reject_if: -> (a) { a[:street].blank? }

  validates_presence_of :name, :contact, :industry, :phone
  validates_uniqueness_of :name, message: 'is already in use'
  validates_format_of :email, with: /\A.+@.+\..+\Z/i, message: 'is not valid'
  validates_format_of [:phone, :cell_phone], with: /\A[0-9]{10}\Z/, allow_nil: true, message: 'is not valid'
  validates_length_of :name, maximum: 40, message: 'is too long'
  validates_length_of :rewards_profile, maximum: 5000, message: 'is too long'
  validates_format_of :website, :facebook, with: %r@\Ahttps?://([\w-]+\.?)+(/[^\s]*)?\Z@i, allow_nil: true, message: 'is not valid'
  validates_attachment_content_type :profile_image, :content_type => [/png\Z/, /jpe?g\Z/]

  strip_attributes collapse_spaces: true
  strip_attributes only: [:phone, :cell_phone], regex: /[^0-9]/

  scope :with_status, -> (show, status) {where("show_statuses->? = ?", show.to_s, status)}

  def to_s
    name
  end

  def merge(into)
    return false if into == self || into.subscriptions.present?

    [:points, :booths, :offers, :payments, :prizes, :signs, :testimonials, :tickets, :users].each do |x|
      self.send(x) << into.send(x)
      self.send(x).each(&:save)
    end

    [:website, :facebook, :cell_phone].each { |x| self[x] ||= into[x] }
    into.cards.update_all(owner_id: self.id, status: 'deleted')

    self.save!
    return into.reload.destroy
  end

  def primary
    users.first
  end
end
