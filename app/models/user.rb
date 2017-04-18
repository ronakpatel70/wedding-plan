class User < ActiveRecord::Base
  include StripeCustomer
  include StripeRecipient

  enum event_role: [:bride, :groom]

  belongs_to :address, dependent: :destroy
  has_many :cards, as: :owner, dependent: :destroy
  belongs_to :default_card, class_name: 'Card'
  has_and_belongs_to_many :events
  has_many :job_applications, dependent: :destroy
  has_many :payments, as: :payer, dependent: :restrict_with_error
  has_many :roles, dependent: :destroy
  has_many :shifts, dependent: :destroy
  has_and_belongs_to_many :shows
  has_many :tickets, dependent: :restrict_with_error
  has_and_belongs_to_many :vendors
  has_secure_password validations: false

  accepts_nested_attributes_for :address, reject_if: -> (a) { a[:street].blank? }
  accepts_nested_attributes_for :events

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :email, case_sensitive: false, message: 'is already in use'
  validates_format_of :email, with: /\A.+@.+\..+\Z/i, message: 'is not valid'
  validates_format_of :phone, with: /\A[0-9]{10}\Z/, allow_nil: true, message: 'is not valid'
  validates_length_of :password, minimum: 8, allow_nil: true

  before_save :set_password_updated_at, if: :password_digest_changed?
  strip_attributes collapse_spaces: true, replace_newlines: true
  strip_attributes only: :phone, regex: /[^0-9]/

  scope :mailable, -> {where(receive_email: true)}
  scope :textable, -> {where(receive_sms: true)}
  scope :admins, -> {joins(:roles).where("roles.type = 0")}
  scope :staff, -> {joins(:roles).where("roles.type = 1")}

  def to_s
    "#{first_name} #{last_name}"
  end

  def authenticate(password)
    return false if locked?

    if super(password)
      update_columns(failed_attempts: 0, locked_at: nil)
    else
      increment!(:failed_attempts)
      update_column 'locked_at', DateTime.now
      false
    end
  end

  def locked?
    if failed_attempts > 4
      DateTime.now <= locked_until
    else
      false
    end
  end

  def locked_until
    locked_at + (2 ** (failed_attempts - 5)).minutes
  end

  private
    def set_password_updated_at
      self.password_updated_at = DateTime.now
    end
end
