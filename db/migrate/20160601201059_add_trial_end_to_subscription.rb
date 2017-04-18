class AddTrialEndToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :trial_end, :datetime
  end
end
