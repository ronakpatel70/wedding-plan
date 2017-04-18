class Token < ApplicationRecord
  belongs_to :user, required: true

  # Generate a token with a random 256-bit ID.
  def self.generate(uid)
    tok = SecureRandom.base64(32)
    exp = Time.now + 30.days
    self.create!(id: tok, user_id: uid, expires_at: exp)
  end
end
