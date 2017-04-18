class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id, null: false
      t.string :stripe_customer_id, null: false
      t.references :vendor, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 0
      t.string :plan, null: false
      t.string :coupon
      t.datetime :current_period_end
      t.datetime :canceled_at

      t.timestamps null: false
    end
  end
end
