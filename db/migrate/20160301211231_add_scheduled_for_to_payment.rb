class AddScheduledForToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :scheduled_for, :date
  end
end
