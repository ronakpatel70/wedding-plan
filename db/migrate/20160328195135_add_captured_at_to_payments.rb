class AddCapturedAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :captured_at, :datetime
    Payment.where(status: [0, 1], scheduled_for: nil).each do |p|
      p.update_column('captured_at', p.created_at)
    end
    Payment.where.not(scheduled_for: nil).where(status: [0, 1]).each do |p|
      p.update_columns(captured_at: p.scheduled_for.to_time + 8.hours, scheduled_for: nil)
    end
  end
end
